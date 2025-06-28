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
  REGION=$(echo "$ZONE" | rev | cut -d'-' -f2- | rev)
  echo "\n📍 VM [$INSTANCE_NAME] nằm ở ZONE: $ZONE | REGION: $REGION"

  create_static_ip() {
    IP_NAME="static-ip-$RANDOM"
    echo "\n⚙️ Tạo IP tĩnh [$IP_NAME] trong $REGION..."
    if ! gcloud compute addresses create "$IP_NAME" --region="$REGION" --quiet; then
      echo "❌ Không thể tạo IP – vượt quota?"
      exit 1
    fi
    STATIC_IP=$(gcloud compute addresses describe "$IP_NAME" --region="$REGION" --format="get(address)")
    echo "$STATIC_IP,$IP_NAME,$REGION" >> created_ips.log
  }

  cleanup_region_ips() {
    echo "\n🧹 Xoá IP không dùng trong vùng [$REGION]..."
    gcloud compute addresses list --filter="status=RESERVED AND region:($REGION)" --format="value(name)" \
    | xargs -r -I {} gcloud compute addresses delete {} --region="$REGION" --quiet
    echo "✅ Đã xoá xong IP không dùng trong vùng."
  }

  cleanup_global_ips() {
    echo "\n🧨 Đang kiểm tra và xoá IP không dùng toàn dự án..."
    mapfile -t IP_ENTRIES < <(gcloud compute addresses list --filter="status=RESERVED" --format="value(name,region)")
    if [ ${#IP_ENTRIES[@]} -eq 0 ]; then echo "✅ Không có IP nào cần xoá."; return; fi
    read -p "⚠️ Xoá ${#IP_ENTRIES[@]} IP không dùng? [Y/n]: " confirm
    confirm=${confirm,,}
    if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then echo "🚫 Huỷ thao tác."; return; fi
    for entry in "${IP_ENTRIES[@]}"; do
      IP_NAME=$(echo "$entry" | awk '{print $1}')
      REGION_URL=$(echo "$entry" | awk '{print $2}')
      REGION_NAME=$(basename "$REGION_URL")
      echo "❌ Xoá IP [$IP_NAME] tại vùng [$REGION_NAME]..."
      gcloud compute addresses delete "$IP_NAME" --region="$REGION_NAME" --quiet
    done
    echo "✅ Đã xoá toàn bộ IP không dùng."
  }

  while true; do
    create_static_ip
    echo "\n🔍 IP tĩnh mới tạo: $STATIC_IP"
    echo "🧭 Chọn hành động:"
    echo "1) Gán IP này cho VM"
    echo "2) Tạo IP mới khác (⚠️ không xoá IP vừa tạo)"
    echo "3) Thoát và xoá IP vừa tạo"
    echo "4) Xoá IP không dùng trong vùng [$REGION]"
    echo "5) Xoá IP không dùng toàn bộ dự án"
    echo "6) ❌ Thoát mà giữ IP đã tạo lại (không gán)"
    read -p "👉 Nhập lựa chọn (1-6): " CHOICE

    case "$CHOICE" in
      1) break ;;
      2) echo "📌 Giữ IP [$STATIC_IP] lại. Tạo IP mới..."; continue ;;
      3) echo "❌ Xoá IP [$STATIC_IP]..."; gcloud compute addresses delete "$IP_NAME" --region="$REGION" --quiet; exit 0 ;;
      4) cleanup_region_ips ;;
      5) cleanup_global_ips ;;
      6)
        echo "📌 Thoát, giữ IP [$STATIC_IP] (không gán)"
        echo "➡️ VM: $INSTANCE_NAME"
        echo "➡️ IP: $STATIC_IP"
        echo "➡️ Region: $REGION"
        exit 0
        ;;
      *) echo "❗ Lựa chọn không hợp lệ. Nhập số từ 1–6." ;;
    esac
  done

  HAS_ACCESS_CONFIG=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
  if [ -n "$HAS_ACCESS_CONFIG" ]; then
    echo "⚠️ Gỡ IP cũ khỏi [$INSTANCE_NAME]..."
    gcloud compute instances delete-access-config $INSTANCE_NAME --access-config-name="external-nat" --zone=$ZONE
  else
    echo "✅ VM chưa có IP public."
  fi

  echo "🔗 Gán IP [$STATIC_IP] vào [$INSTANCE_NAME]..."
  gcloud compute instances add-access-config $INSTANCE_NAME --access-config-name="external-nat" --address=$STATIC_IP --zone=$ZONE
  echo "🎉 HOÀN TẤT! [$INSTANCE_NAME] đang dùng IP: $STATIC_IP"
}

# ======================== XOÁ TOÀN BỘ IP KHÔNG DÙNG ========================
cleanup_global_ips_direct() {
  echo "\n🧨 Đang kiểm tra và xoá IP không dùng toàn bộ dự án..."
  mapfile -t IP_ENTRIES < <(gcloud compute addresses list --filter="status=RESERVED" --format="value(name,region)")
  if [ ${#IP_ENTRIES[@]} -eq 0 ]; then echo "✅ Không có IP nào cần xoá."; return; fi

  LOGFILE="deleted_ips_$(date +%Y%m%d_%H%M%S).log"

  read -p "⚠️ Sẽ xoá ${#IP_ENTRIES[@]} IP không dùng. Xác nhận? [Y/n]: " confirm
  confirm=${confirm,,}
  if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then echo "🚫 Huỷ thao tác."; return; fi

  for entry in "${IP_ENTRIES[@]}"; do
    IP_NAME=$(echo "$entry" | awk '{print $1}')
    REGION_URL=$(echo "$entry" | awk '{print $2}')
    REGION_NAME=$(basename "$REGION_URL")
    echo "❌ Đang xoá IP [$IP_NAME] tại vùng [$REGION_NAME]..."
    echo "$IP_NAME,$REGION_NAME" >> "$LOGFILE"
    gcloud compute addresses delete "$IP_NAME" --region="$REGION_NAME" --quiet
  done
  echo "✅ Đã xoá toàn bộ IP không dùng. Log lưu tại: $LOGFILE"
}

# ======================== MENU CHÍNH ========================
echo -e "\n🌐 Chọn thao tác:"
echo "1) Tạo nhiều VM"
echo "2) Đổi IP VM"
echo "3) Xoá tất cả IP tĩnh không dùng (toàn bộ dự án)"
read -p "👉 Nhập lựa chọn (1/2/3): " MAIN_CHOICE

case "$MAIN_CHOICE" in
  1) create_vm_flow ;;
  2) change_ip_flow ;;
  3) cleanup_global_ips_direct ;;
  *) echo "❌ Lựa chọn không hợp lệ. Thoát."; exit 1 ;;
esac
