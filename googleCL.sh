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
  NETWORK_TIER="STANDARD"
  [[ "$TIER_OPTION" == "2" ]] && NETWORK_TIER="PREMIUM"

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

# ======================== CHỨC NĂNG TẠO FIREWALL ========================
create_firewall_rule_random() {
  echo -e "\n🌐 Đang tạo firewall rule..."
  read -p "🔐 Nhập port cần mở (ví dụ: 22 hoặc 22,80,443): " PORTS
  if [[ -z "$PORTS" ]]; then
    echo "❌ Bạn chưa nhập port."
    return
  fi
  RULE_NAME="fw-rule-$(date +%Y%m%d-%H%M%S)-$RANDOM"
  echo "⚙️ Đang tạo rule có tên: $RULE_NAME"

  gcloud compute firewall-rules create "$RULE_NAME" \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules="tcp:$PORTS" \
    --source-ranges=0.0.0.0/0

  if [ $? -eq 0 ]; then
    echo "✅ Đã tạo firewall rule: $RULE_NAME cho port: $PORTS"
  else
    echo "❌ Lỗi khi tạo firewall rule."
  fi
}

# ======================== CHỨC NĂNG TẠO VM ========================
create_vm_flow() {
  zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
  zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

  echo -e "\n🌏 Nhập số lượng VM Tokyo muốn tạo (0 để bỏ, mặc định 4): "
  read -p "Tokyo: " COUNT_TOKYO
  COUNT_TOKYO=${COUNT_TOKYO:-4}
  [[ ! "$COUNT_TOKYO" =~ ^[0-9]+$ ]] && COUNT_TOKYO=4

  echo -e "\n🌏 Nhập số lượng VM Osaka muốn tạo (0 để bỏ, mặc định 4): "
  read -p "Osaka: " COUNT_OSAKA
  COUNT_OSAKA=${COUNT_OSAKA:-4}
  [[ ! "$COUNT_OSAKA" =~ ^[0-9]+$ ]] && COUNT_OSAKA=4

  if [ "$COUNT_TOKYO" -eq 0 ] && [ "$COUNT_OSAKA" -eq 0 ]; then
    echo "❌ Cần tạo ít nhất VM ở 1 vùng. Thoát."
    return
  fi

  read -p "✏️ Nhập prefix tên VM Tokyo (mặc định: tokyo): " CUSTOM_PREFIX_TOKYO
  PREFIX_TOKYO=${CUSTOM_PREFIX_TOKYO:-tokyo}

  read -p "✏️ Nhập prefix tên VM Osaka (mặc định: osaka): " CUSTOM_PREFIX_OSAKA
  PREFIX_OSAKA=${CUSTOM_PREFIX_OSAKA:-osaka}

  echo "🌐 Chọn loại IP:"
  echo "1) Có IP công cộng (Public IP – sẽ gán IP tĩnh riêng)"
  echo "2) Không có IP công cộng (Private only)"
  read -p "🔌 Nhập lựa chọn [1-2] (mặc định: 1): " IP_OPTION
  IP_OPTION=${IP_OPTION:-1}

  NETWORK_TIER="STANDARD"
  if [ "$IP_OPTION" == "1" ]; then
    echo "📶 Chọn Network Tier cho IP:"
    echo "1) STANDARD 🔹"
    echo "2) PREMIUM"
    read -p "💡 Nhập lựa chọn [1-2] (mặc định: 1): " TIER_OPTION
    TIER_OPTION=${TIER_OPTION:-1}
    [[ "$TIER_OPTION" == "2" ]] && NETWORK_TIER="PREMIUM"
  fi

  create_vms_in_zone() {
    local COUNT=$1
    local PREFIX=$2
    local ZONES=("${!3}")
    for ((i=1; i<=COUNT; i++)); do
      ZONE="${ZONES[((i-1)%${#ZONES[@]})]}"
      REGION=$(echo "$ZONE" | rev | cut -d'-' -f2- | rev)
      num=$(printf "%02d" $((RANDOM % 100)))
      name="${PREFIX}${num}"

      if gcloud compute instances describe "$name" --zone="$ZONE" &>/dev/null; then
        echo "⚠️ VM $name đã tồn tại ở $ZONE. Bỏ qua."
        continue
      fi

      if [ "$IP_OPTION" == "1" ]; then
        IP_NAME="ip-${name}"
        echo "⚙️ Tạo IP tĩnh [$IP_NAME] trong [$REGION]..."
        if ! gcloud compute addresses create "$IP_NAME" --region="$REGION" --network-tier="$NETWORK_TIER" --quiet; then
          echo "❌ Không tạo được IP [$IP_NAME]. Bỏ qua VM."
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

  [ "$COUNT_TOKYO" -gt 0 ] && create_vms_in_zone "$COUNT_TOKYO" "$PREFIX_TOKYO" zones_tokyo[@]
  [ "$COUNT_OSAKA" -gt 0 ] && create_vms_in_zone "$COUNT_OSAKA" "$PREFIX_OSAKA" zones_osaka[@]
  echo "🚀 Hoàn thành tạo VM."
}

# ======================== ĐỔI IP VM ========================
change_ip_flow() {
  echo "📦 Lấy danh sách VM..."
  INSTANCES=($(gcloud compute instances list --format="value(name)"))
  [ ${#INSTANCES[@]} -eq 0 ] && echo "❌ Không có VM nào." && exit 1

  echo "💻 Chọn VM để đổi IP:"
  select INSTANCE_NAME in "${INSTANCES[@]}"; do
    [ -n "$INSTANCE_NAME" ] && break
  done

  ZONE=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format="value(zone)" | rev | cut -d'/' -f1 | rev)
  REGION=$(echo "$ZONE" | rev | cut -d'-' -f2- | rev)

  echo "📶 Chọn Network Tier cho IP mới:"
  echo "1) STANDARD 🔹"
  echo "2) PREMIUM"
  read -p "💡 Nhập lựa chọn [1-2] (mặc định: 1): " TIER_OPTION
  TIER_OPTION=${TIER_OPTION:-1}
  NETWORK_TIER="STANDARD"
  [[ "$TIER_OPTION" == "2" ]] && NETWORK_TIER="PREMIUM"

  IP_NAME="static-ip-$RANDOM"
  gcloud compute addresses create "$IP_NAME" --region="$REGION" --network-tier="$NETWORK_TIER" --quiet
  STATIC_IP=$(gcloud compute addresses describe "$IP_NAME" --region="$REGION" --format="get(address)")

  gcloud compute instances delete-access-config "$INSTANCE_NAME" --access-config-name="external-nat" --zone="$ZONE" &>/dev/null
  gcloud compute instances add-access-config "$INSTANCE_NAME" --zone="$ZONE" --address="$STATIC_IP" --network-tier="$NETWORK_TIER"

  echo "✅ Đã gán IP mới [$STATIC_IP] cho [$INSTANCE_NAME]"
}

# ======================== XOÁ IP KHỎI VM ========================
remove_ip_from_vm() {
  echo "📦 Lấy danh sách VM..."
  INSTANCES=($(gcloud compute instances list --format="value(name)"))
  [ ${#INSTANCES[@]} -eq 0 ] && echo "❌ Không có VM nào." && return

  echo "💻 Chọn VM để xoá IP:"
  select INSTANCE_NAME in "${INSTANCES[@]}"; do
    [ -n "$INSTANCE_NAME" ] && break
  done

  ZONE=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format="value(zone)" | rev | cut -d'/' -f1 | rev)
  NAT_IP=$(gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
  [ -z "$NAT_IP" ] && echo "⚠️ VM không có IP công cộng." && return

  read -p "❓ Bạn có chắc muốn xoá IP khỏi VM [$INSTANCE_NAME]? [Y/n]: " CONFIRM
  CONFIRM=${CONFIRM,,}
  [[ "$CONFIRM" =~ ^(n|no)$ ]] && echo "🚫 Huỷ thao tác." && return

  gcloud compute instances delete-access-config "$INSTANCE_NAME" --access-config-name="external-nat" --zone="$ZONE"
  echo "✅ Đã xoá IP khỏi [$INSTANCE_NAME]"
}

# ======================== XOÁ TOÀN BỘ IP KHÔNG DÙNG ========================
cleanup_global_ips_direct() {
  echo "🧨 Kiểm tra IP không dùng..."
  mapfile -t IP_ENTRIES < <(gcloud compute addresses list --filter="status=RESERVED" --format="value(name,region)")
  [ ${#IP_ENTRIES[@]} -eq 0 ] && echo "✅ Không có IP nào cần xoá." && return

  read -p "⚠️ Xác nhận xoá ${#IP_ENTRIES[@]} IP không dùng? [Y/n]: " confirm
  confirm=${confirm,,}
  [[ "$confirm" =~ ^(n|no)$ ]] && echo "🚫 Huỷ thao tác." && return

  for entry in "${IP_ENTRIES[@]}"; do
    IP_NAME=$(echo "$entry" | awk '{print $1}')
    REGION_URL=$(echo "$entry" | awk '{print $2}')
    REGION_NAME=$(basename "$REGION_URL")
    echo "❌ Xoá IP [$IP_NAME] ở [$REGION_NAME]..."
    gcloud compute addresses delete "$IP_NAME" --region="$REGION_NAME" --quiet
  done
  echo "✅ Đã xoá toàn bộ IP không dùng."
}

# ======================== MENU CHÍNH ========================
echo -e "\n🌐 Chọn thao tác:"
echo "1) Tạo nhiều VM"
echo "2) Đổi IP VM"
echo "3) Xoá tất cả IP không dùng (toàn bộ dự án)"
echo "4) Xoá IP khỏi 1 VM"
echo "5) Tạo nhiều IP tĩnh"
echo "6) Tạo firewall rule (tên random)"
read -p "👉 Nhập lựa chọn (1-6) (mặc định: 4): " MAIN_CHOICE
MAIN_CHOICE=${MAIN_CHOICE:-4}

case "$MAIN_CHOICE" in
  1) create_vm_flow ;;
  2) change_ip_flow ;;
  3) cleanup_global_ips_direct ;;
  4) remove_ip_from_vm ;;
  5) create_ip_batch ;;
  6) create_firewall_rule_random ;;
  *) echo "❌ Lựa chọn không hợp lệ. Thoát." && exit 1 ;;
esac
