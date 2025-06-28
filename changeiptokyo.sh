#!/bin/bash

# ======================== CHỨC NĂNG TẠO VM ========================
create_vm_flow() {
  zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
  zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

  echo -e "\n🌏 Chọn khu vực:"
  echo "1) Tokyo (asia-northeast1)"
  echo "2) Osaka (asia-northeast2)"
  read -p "Nhập số [1-2]: " REGION_CHOICE

  case $REGION_CHOICE in
    1)
      REGION="asia-northeast1"
      ZONES=("${zones_tokyo[@]}")
      PREFIX="tokyo"
      ;;
    2)
      REGION="asia-northeast2"
      ZONES=("${zones_osaka[@]}")
      PREFIX="osaka"
      ;;
    *)
      echo "❌ Lựa chọn không hợp lệ. Thoát script."
      exit 1
      ;;
  esac

  echo -e "\n📌 Chọn zone trong vùng $REGION:"
  for i in "${!ZONES[@]}"; do
    echo "$((i+1))) ${ZONES[$i]}"
  done

  read -p "➡️ Nhập số tương ứng với zone (hoặc Enter để tạo rải đều): " ZONE_INDEX
  if [ -n "$ZONE_INDEX" ]; then
    ZONE_INDEX=$((ZONE_INDEX - 1))
    if [ "$ZONE_INDEX" -lt 0 ] || [ "$ZONE_INDEX" -ge "${#ZONES[@]}" ]; then
      echo "❌ Zone không hợp lệ. Thoát script."
      exit 1
    fi
    ZONES=("${ZONES[$ZONE_INDEX]}")
  fi

  read -p "✏️ Nhập prefix đặt tên VM (mặc định: $PREFIX): " CUSTOM_PREFIX
  PREFIX=${CUSTOM_PREFIX:-$PREFIX}

  read -p "🔢 Nhập số lượng VM muốn tạo (mặc định: 24): " COUNT
  COUNT=${COUNT:-24}

  echo "🌐 Chọn loại IP:"
  echo "1) Có IP công cộng (Public IP – sẽ gán IP tĩnh riêng)"
  echo "2) Không có IP công cộng (Private only)"
  read -p "🔌 Nhập lựa chọn [1-2] (mặc định: 1): " IP_OPTION
  IP_OPTION=${IP_OPTION:-1}

  echo -e "\n🚀 Đang tạo $COUNT VM tại vùng: $REGION..."

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
      echo "⚙️ Tạo IP tĩnh [$IP_NAME] trong vùng [$REGION]..."
      if ! gcloud compute addresses create "$IP_NAME" --region="$REGION" --quiet; then
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
        --address="$STATIC_IP"
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

# ======================== CHỨC NĂNG ĐỔI IP ========================
change_ip_flow() {
  echo "\n📦 Lấy danh sách VM..."
  INSTANCES=($(gcloud compute instances list --format="value(name)"))
  if [ ${#INSTANCES[@]} -eq 0 ]; then echo "❌ Không tìm thấy VM nào."; exit 1; fi

  echo "💻 Chọn VM để gán IP:"
  select INSTANCE_NAME in "${INSTANCES[@]}"; do
    if [ -n "$INSTANCE_NAME" ]; then break; else echo "❗ Chọn số hợp lệ."; fi
  done

  ZONE=$(gcloud compute instances list --filter="name=($INSTANCE_NAME)" --format="value(zone)" | rev | cut -d'/' -f1 | rev)
  REGION=$(echo "$ZONE" | rev | c
