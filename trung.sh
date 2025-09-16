#!/bin/bash

# ======================== CHỨC NĂNG TẠO IP ========================
create_ip_batch() {
  echo -e "\n🌍 Chọn khu vực tạo IP:"
  echo "1) Tokyo (asia-northeast1)"
  echo "2) Osaka (asia-northeast2)"
  read -p "Nhập số [1-2]: " REGION_CHOICE

  case $REGION_CHOICE in
    1) REGION="asia-northeast1" ;;
    2) REGION="asia-northeast2" ;;
    *) echo "❌ Lựa chọn không hợp lệ."; return ;;
  esac

  echo -e "\n📶 Chọn Network Tier cho IP:"
  echo "1) STANDARD (giá rẻ) 🔹"
  echo "2) PREMIUM"
  read -p "💡 Nhập lựa chọn [1-2] (mặc định: 1): " TIER_OPTION
  TIER_OPTION=${TIER_OPTION:-1}
  if [ "$TIER_OPTION" == "1" ]; then
    NETWORK_TIER="STANDARD"
  else
    NETWORK_TIER="PREMIUM"
  fi

  read -p "🔢 Nhập số lượng IP muốn tạo: " IP_COUNT
  if ! [[ "$IP_COUNT" =~ ^[0-9]+$ ]] || [ "$IP_COUNT" -le 0 ]; then
    echo "❌ Số lượng không hợp lệ."; return
  fi

  echo -e "\n🚀 Đang tạo $IP_COUNT IP ($NETWORK_TIER) tại vùng $REGION..."
  for ((i=1; i<=IP_COUNT; i++)); do
    IP_NAME="custom-ip-$RANDOM"
    if gcloud compute addresses create "$IP_NAME" --region="$REGION" --network-tier="$NETWORK_TIER" --quiet; then
      IP_ADDR=$(gcloud compute addresses describe "$IP_NAME" --region="$REGION" --format="get(address)")
      echo "✅ Đã tạo IP [$IP_ADDR] tên [$IP_NAME] tại [$REGION]"
    else
      echo "❌ Không thể tạo IP [$IP_NAME]. Có thể vượt quota."
    fi
  done
}

# ======================== CHỨC NĂNG TẠO VM (CẬP NHẬT) ========================
create_vm_flow() {
  zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
  zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

  echo -e "\n🌐 Tạo VM đồng thời cho 2 vùng: Tokyo và Osaka"

  read -p "🔢 Nhập số lượng VM tạo cho Tokyo (nhập 0 để bỏ qua, mặc định 4): " COUNT_TOKYO
  COUNT_TOKYO=${COUNT_TOKYO:-4}
  if ! [[ "$COUNT_TOKYO" =~ ^[0-9]+$ ]] || [ "$COUNT_TOKYO" -lt 0 ]; then
    echo "❌ Số lượng không hợp lệ. Mặc định là 4"
    COUNT_TOKYO=4
  fi

  read -p "✏️ Nhập prefix đặt tên VM cho Tokyo (mặc định: tokyo): " PREFIX_TOKYO
  PREFIX_TOKYO=${PREFIX_TOKYO:-tokyo}

  read -p "🔢 Nhập số lượng VM tạo cho Osaka (nhập 0 để bỏ qua, mặc định 4): " COUNT_OSAKA
  COUNT_OSAKA=${COUNT_OSAKA:-4}
  if ! [[ "$COUNT_OSAKA" =~ ^[0-9]+$ ]] || [ "$COUNT_OSAKA" -lt 0 ]; then
    echo "❌ Số lượng không hợp lệ. Mặc định là 4"
    COUNT_OSAKA=4
  fi

  read -p "✏️ Nhập prefix đặt tên VM cho Osaka (mặc định: osaka): " PREFIX_OSAKA
  PREFIX_OSAKA=${PREFIX_OSAKA:-osaka}

  echo -e "\n🌐 Chọn loại IP (áp dụng cho cả 2 vùng):"
  echo "1) Có IP công cộng (Public IP – sẽ gán IP tĩnh riêng)"
  echo "2) Không có IP công cộng (Private only)"
  read -p "🔌 Nhập lựa chọn [1-2] (mặc định: 1): " IP_OPTION
  IP_OPTION=${IP_OPTION:-1}

  if [ "$IP_OPTION" == "1" ]; then
    echo "📶 Chọn Network Tier cho IP:"
    echo "1) STANDARD (giá rẻ, đủ dùng) 🔹"
    echo "2) PREMIUM (ưu tiên mạng Google, giá cao hơn)"
    read -p "💡 Nhập lựa chọn [1-2] (mặc định: 1): " TIER_OPTION
    TIER_OPTION=${TIER_OPTION:-1}
    if [ "$TIER_OPTION" == "1" ]; then
      NETWORK_TIER="STANDARD"
    else
      NETWORK_TIER="PREMIUM"
    fi
  fi

  create_vms_in_region() {
    local REGION=$1
    local ZONES=("${!2}")
    local COUNT=$3
    local PREFIX=$4

    if [ "$COUNT" -eq 0 ]; then
      echo "⚠️ Bỏ qua tạo VM tại vùng $REGION (số lượng = 0)"
      return
    fi

    echo -e "\n🚀 Đang tạo $COUNT VM tại vùng: $REGION với prefix tên: $PREFIX"

    for ((i=1; i<=COUNT; i++)); do
      ZONE="${ZONES[((i-1)%${#ZONES[@]})]}"
      num=$(printf "%02d" $((RANDOM % 100)))
      name="${PREFIX}${num}"

      if gcloud compute instances describe "$name" --zone="$ZONE" &>/dev/null; then
        echo "⚠️ VM $name đã tồn tại ở $ZONE. Bỏ qua."
        continue
      fi

      if [ "$IP_OPTION" == "1" ]; then
        IP_NAME="ip-${name}"
        echo "⚙️ Tạo IP tĩnh [$IP_NAME] trong vùng [$REGION]..."
        if ! gcloud compute addresses create "$IP_NAME" --region="$REGION" --network-tier="$NETWORK_TIER" --quiet; then
          echo "❌ Không tạo được IP [$IP_NAME]. Có thể vượt quota. Bỏ qua VM này."
          continue
        fi
        STATIC_IP=$(gcloud compute addresses describe "$IP_NAME" --region="$REGION" --format="get(address)")
        echo "🛠️ Tạo VM [$name] ở $ZONE với IP: $STATIC_IP"
        gcloud compute instances create "$name" \
          --zone="$ZONE" \
          --machine-type=e2-micro \
          --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
          --image-project=ubuntu-os-cloud \
          --boot-disk-size=10GB \
          --address="$STATIC_IP" \
          --network-tier="$NETWORK_TIER"
        echo "$name,$STATIC_IP,$ZONE" >> created_vms.log
      else
        echo "🔒 Tạo VM [$name] không có IP công cộng ở $ZONE"
        gcloud compute instances create "$name" \
          --zone="$ZONE" \
          --machine-type=e2-micro \
          --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
          --image-project=ubuntu-os-cloud \
          --boot-disk-size=10GB \
          --no-address
        echo "$name,NONE,$ZONE" >> created_vms.log
      fi
      echo "✅ Đã tạo: $name"
    done
  }

  create_vms_in_region "asia-northeast1" zones_tokyo[@] "$COUNT_TOKYO" "$PREFIX_TOKYO"
  create_vms_in_region "asia-northeast2" zones_osaka[@] "$COUNT_OSAKA" "$PREFIX_OSAKA"
}

# ======================== CHỨC NĂNG ĐỔI IP ========================
change_ip_flow() {
  echo "
📦 Lấy danh sách VM..."
  INSTANCES=($(gcloud compute instances list --format="value(name)"))
  if [ ${#INSTANCES[@]} -eq 0 ]; then echo "❌ Không tìm thấy VM nào."; exit 1; fi

  echo "💻 Chọn VM để gán IP:"
  select INSTANCE_NAME in "${INSTANCES[@]}"; do
    if [ -n "$INSTANCE_NAME" ]; then break; else echo "❗ Chọn số hợp lệ."; fi
  done

  ZONE=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format="value(zone)" | rev | cut -d'/' -f1 | rev)
  REGION=$(echo "$ZONE" | rev | cut -d'-' -f2- | rev)
  echo "
📍 VM [$INSTANCE_NAME] nằm ở ZONE: $ZONE | REGION: $REGION"

  echo "📶 Chọn Network Tier cho IP mới:"
  echo "1) STANDARD (giá rẻ) 🔹"
  echo "2) PREMIUM (mặc định)"
  read -p "💡 Nhập lựa chọn [1-2] (mặc định: 1): " TIER_OPTION
  TIER_OPTION=${TIER_OPTION:-1}
  if [ "$TIER_OPTION" == "1" ]; then
    NETWORK_TIER="STANDARD"
  else
    NETWORK_TIER="PREMIUM"
  fi

  IP_NAME="static-ip-$RANDOM"
  echo "
⚙️ Tạo IP tĩnh [$IP_NAME] trong $REGION..."
  gcloud compute addresses create "$IP_NAME" --region="$REGION" --network-tier="$NETWORK_TIER" --quiet
  STATIC_IP=$(gcloud compute addresses describe "$IP_NAME" --region="$REGION" --format="get(address)")

  echo "🔗 Gán IP [$STATIC_IP] vào [$INSTANCE_NAME]..."
  gcloud compute instances delete-access-config "$INSTANCE_NAME" --access-config-name="external-nat" --zone="$ZONE" &>/dev/null
  gcloud compute instances add-access-config "$INSTANCE_NAME" \
    --access-config-name="external-nat" \
    --address="$STATIC_IP" \
    --zone="$ZONE" \
    --network-tier="$NETWORK_TIER"

  echo "✅ VM [$INSTANCE_NAME] đã gán IP mới: $STATIC_IP"
}

# ======================== XOÁ IP KHỎI VM ========================
remove_ip_from_vm() {
  echo "
📦 Lấy danh sách VM..."
  INSTANCES=($(gcloud compute instances list --format="value(name)"))
  if [ ${#INSTANCES[@]} -eq 0 ]; then echo "❌ Không tìm thấy VM nào."; exit 1; fi

  echo "💻 Chọn VM muốn xoá IP:"
  select INSTANCE_NAME in "${INSTANCES[@]}"; do
    if [ -n "$INSTANCE_NAME" ]; then break; else echo "❗ Chọn số hợp lệ."; fi
  done

  ZONE=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format="value(zone)" | rev | cut -d'/' -f1 | rev)
  NAT_IP=$(gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

  if [ -z "$NAT_IP" ]; then
    echo "⚠️ VM [$INSTANCE_NAME] không có IP công cộng để xoá."
    return
  fi

  echo "⚠️ VM [$INSTANCE_NAME] đang có IP: $NAT_IP"
  read -p "❓ Bạn có chắc muốn xoá IP khỏi VM này? [Y/n]: " CONFIRM
  CONFIRM=${CONFIRM,,}
  if [[ "$CONFIRM" == "n" || "$CONFIRM" == "no" ]]; then
    echo "🚫 Huỷ thao tác xoá IP."
    return
  fi

  echo "❌ Đang xoá IP khỏi [$INSTANCE_NAME]..."
  gcloud compute instances delete-access-config "$INSTANCE_NAME" --access-config-name="external-nat" --zone="$ZONE"
  echo "✅ Đã xoá IP khỏi VM [$INSTANCE_NAME]"
}

# ======================== MENU CHÍNH ========================
while true; do
  clear
  echo "==================== QUẢN LÝ VM GCP ===================="
  echo "1) Tạo VM Tokyo & Osaka"
  echo "2) Tạo IP tĩnh"
  echo "3) Đổi IP tĩnh cho VM"
  echo "4) Xoá IP công cộng khỏi VM"
  echo "5) Thoát"
  read -p "Chọn chức năng [1-5]: " CHOICE

  case $CHOICE in
    1) create_vm_flow ;;
    2) create_ip_batch ;;
    3) change_ip_flow ;;
    4) remove_ip_from_vm ;;
    5) echo "👋 Bye!"; exit 0 ;;
    *) echo "❌ Lựa chọn không hợp lệ." ; sleep 1 ;;
  esac
  echo -e "\nNhấn Enter để tiếp tục..."
  read
done
