#!/bin/bash

# 🖊️ Nhập tên máy ảo (VM) cần gán IP
read -p "Nhập tên VM (INSTANCE_NAME): " INSTANCE_NAME

# Kiểm tra nếu người dùng không nhập
if [ -z "$INSTANCE_NAME" ]; then
  echo "❌ Bạn chưa nhập tên VM. Thoát script."
  exit 1
fi

# ⚙️ Các biến khác
ZONE="asia-northeast1-b"
REGION="asia-northeast1"
IP_NAME="static-ip-$RANDOM"

echo "🚀 Đang tạo IP tĩnh [$IP_NAME] trong vùng $REGION..."
gcloud compute addresses create $IP_NAME --region=$REGION

# Lấy IP vừa tạo
STATIC_IP=$(gcloud compute addresses describe $IP_NAME \
  --region=$REGION \
  --format="get(address)")

echo "✅ IP tĩnh được tạo: $STATIC_IP"

echo "⚠️ Gỡ IP hiện tại khỏi VM [$INSTANCE_NAME] (nếu có)..."
gcloud compute instances delete-access-config $INSTANCE_NAME \
  --access-config-name="external-nat" \
  --zone=$ZONE || echo "👉 Không có IP hiện tại để xoá hoặc đã bị xoá."

echo "🔗 Gán IP tĩnh [$STATIC_IP] vào VM [$INSTANCE_NAME]..."
gcloud compute instances add-access-config $INSTANCE_NAME \
  --access-config-name="external-nat" \
  --address=$STATIC_IP \
  --zone=$ZONE

echo "🎉 Xong! VM [$INSTANCE_NAME] hiện đang dùng IP tĩnh:"
echo "$STATIC_IP"
