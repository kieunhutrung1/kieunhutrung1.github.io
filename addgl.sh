#!/bin/bash

# 🗾 Danh sách zone của Tokyo và Osaka
zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

# 🌍 Chọn khu vực
echo "🌏 Chọn khu vực:"
echo "1) Tokyo (asia-northeast1)"
echo "2) Osaka (asia-northeast2)"
read -p "Nhập số [1-2]: " REGION_CHOICE

case $REGION_CHOICE in
  1)
    REGION="asia-northeast1"
    ZONES=("${zones_tokyo[@]}")
    PREFIX="T"
    ;;
  2)
    REGION="asia-northeast2"
    ZONES=("${zones_osaka[@]}")
    PREFIX="S"
    ;;
  *)
    echo "❌ Lựa chọn không hợp lệ. Thoát script."
    exit 1
    ;;
esac

# 🧭 Nhập zone cụ thể
echo "📌 Các zone trong $REGION:"
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

echo "🚀 Bắt đầu tạo $COUNT VM tại $ZONE..."

for ((i=1; i<=COUNT; i++)); do
  # Sinh số ngẫu nhiên 2 chữ số từ 00–99
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
