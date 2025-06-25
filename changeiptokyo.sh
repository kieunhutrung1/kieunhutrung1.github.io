#!/bin/bash

# ⚙️ Cấu hình
INSTANCE_NAME="tokyo-3"
ZONE="asia-northeast1-b"
REGION="asia-northeast1"
IP_NAME="static-ip-$RANDOM"  # tên IP tĩnh random

echo "🚀 Tạo IP tĩnh [$IP_NAME] trong vùng $REGION..."
gcloud compute addresses create $IP_NAME --region=$REGION

# Lấy địa chỉ IP thực tế vừa tạo
STATIC_IP=$(gcloud compute addresses describe $IP_NAME \
  --region=$REGION \
  --format="get(address)")

echo "✅ IP tĩnh vừa tạo: $STATIC_IP"

echo "⚠️ Gỡ IP động hiện tại khỏi VM $INSTANCE_NAME..."
gcloud compute instances delete-access-config $INSTANCE_NAME \
  --access-config-name="external-nat" \
  --zone=$ZONE

echo "🔗 Gán IP tĩnh [$STATIC_IP] vào VM..."
gcloud compute instances add-access-config $INSTANCE_NAME \
  --access-config-name="external-nat" \
  --address=$STATIC_IP \
  --zone=$ZONE

echo "✅ Đã gán IP tĩnh thành công:"
echo "$INSTANCE_NAME --> $STATIC_IP"
