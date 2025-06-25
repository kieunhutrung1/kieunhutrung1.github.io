#!/bin/bash

# 🗾 Các zone tương ứng theo vùng
zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

# 🌏 Chọn vùng (Tokyo hoặc Osaka)
echo "🌍 Chọn khu vực:"
echo "1) Tokyo (asia-northeast1)"
echo "2) Osaka (asia-northeast2)"
read -p "Nhập số [1-2]: " REGION_CHOICE

case $REGION_CHOICE in
  1)
    REGION="asia-northeast1"
    ZONES=("${zones_tokyo[@]}")
    ;;
  2)
    REGION="asia-northeast2"
    ZONES=("${zones_osaka[@]}")
    ;;
  *)
    echo "❌ Lựa chọn không hợp lệ. Thoát script."
    exit 1
    ;;
esac

# 📍 Hiển thị zone cho người chọn
echo "📌 Các zone khả dụng trong $REGION:"
for z in "${ZONES[@]}"; do
  echo "- $z"
done

read -p "➡️ Nhập zone bạn muốn dùng (phải khớp danh sách trên): " ZONE
if [[ ! " ${ZONES[*]} " =~ " $ZONE " ]]; then
  echo "❌ Zone không hợp lệ cho vùng đã chọn. Thoát script."
  exit 1
fi

# 🔢 Nhập số lượng máy ảo
read -p "🔢 Nhập số lượng VM muốn tạo (mặc định: 4): " COUNT
COUNT=${COUNT:-4}

echo "🚀 Bắt đầu tạo $COUNT VM tại zone $ZONE..."

for ((i=1; i<=COUNT; i++)); do
  rand=$(tr -dc a-z </dev/urandom | head -c 3)
  name="${ZONE}-${rand}"

  echo "🛠️ Đang tạo VM: $name"

  gcloud compute instances create "$name" \
    --zone="$ZONE" \
    --machine-type=e2-micro \
    --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB

  echo "✅ Đã tạo: $name"
done
