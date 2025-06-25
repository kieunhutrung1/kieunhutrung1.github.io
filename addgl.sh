#!/bin/bash

# 🗾 Danh sách zone của từng vùng
zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

# 🌍 Chọn vùng
echo "🌏 Chọn khu vực:"
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

# 📍 Chọn zone theo số
echo "📌 Chọn zone trong vùng $REGION:"
for i in "${!ZONES[@]}"; do
  echo "$((i+1))) ${ZONES[$i]}"
done

read -p "➡️ Nhập số tương ứng với zone: " ZONE_INDEX
ZONE_INDEX=$((ZONE_INDEX - 1))

if [ "$ZONE_INDEX" -lt 0 ] || [ "$ZONE_INDEX" -ge "${#ZONES[@]}" ]; then
  echo "❌ Zone không hợp lệ. Thoát script."
  exit 1
fi

ZONE="${ZONES[$ZONE_INDEX]}"

# 🔢 Nhập số lượng VM cần tạo
read -p "🔢 Nhập số lượng VM muốn tạo (mặc định: 4): " COUNT
COUNT=${COUNT:-4}

echo "🚀 Đang tạo $COUNT VM tại zone: $ZONE..."

for ((i=1; i<=COUNT; i++)); do
  num=$(printf "%02d" $((RANDOM % 100)))
  name="${PREFIX}${num}"

  echo "🛠️ Đang tạo VM: $name"

  gcloud compute instances create "$name" \
    --zone="$ZONE" \
    --machine-type=e2-micro \
    --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB

  echo "✅ Đã tạo: $name"
done
