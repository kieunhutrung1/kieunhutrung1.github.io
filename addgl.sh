#!/bin/bash

# 🛠️ Script tạo nhiều VM Google Cloud, tên máy = zone + random

# Nhập số lượng VM từ người dùng
read -p "🔢 Nhập số lượng VM muốn tạo (mặc định: 4): " COUNT
COUNT=${COUNT:-4}

# Danh sách zone theo vùng
zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")

echo "📦 Đang chuẩn bị tạo $COUNT VM..."

for ((i=1; i<=COUNT; i++)); do
  # Sinh chuỗi random
  rand=$(tr -dc a-z </dev/urandom | head -c 3)

  # Chọn ngẫu nhiên vùng (Tokyo hoặc Osaka)
  if (( RANDOM % 2 == 0 )); then
    ZONES=("${zones_tokyo[@]}")
  else
    ZONES=("${zones_osaka[@]}")
  fi

  # Chọn zone ngẫu nhiên từ vùng đã chọn
  random_zone=${ZONES[$RANDOM % ${#ZONES[@]}]}

  # Tên máy = zone + "-" + random
  name="${random_zone}-${rand}"

  echo "🚀 Creating VM: $name in $random_zone..."

  gcloud compute instances create "$name" \
    --zone="$random_zone" \
    --machine-type=e2-micro \
    --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB

  echo "✅ Done: $name in $random_zone"
done
