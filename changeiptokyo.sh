#!/bin/bash

# 🖊️ Nhập tên VM
read -p "👉 Nhập tên VM (INSTANCE_NAME): " INSTANCE_NAME
if [ -z "$INSTANCE_NAME" ]; then
  echo "❌ Bạn chưa nhập tên VM. Thoát script."
  exit 1
fi

# 📍 Chọn REGION
echo "🌏 Chọn REGION:"
select REGION in asia-northeast1 asia-northeast2; do
  if [ -n "$REGION" ]; then
    break
  else
    echo "❗️ Vui lòng chọn một số hợp lệ (1–2)."
  fi
done

# 📍 Chọn ZONE dựa theo REGION
if [ "$REGION" == "asia-northeast1" ]; then
  ZONES=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
elif [ "$REGION" == "asia-northeast2" ]; then
  ZONES=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")
fi

echo "🌐 Chọn ZONE trong $REGION:"
select ZONE in "${ZONES[@]}"; do
  if [ -n "$ZONE" ]; then
    break
  else
    echo "❗️ Vui lòng chọn một số hợp lệ."
  fi
done

# ⚙️ Tạo IP tĩnh
IP_NAME="static-ip-$RANDOM"

echo "🚀 Tạo IP tĩnh [$IP_NAME] trong vùng $REGION..."
gcloud compute addresses create $IP_NAME --region=$REGION

STATIC_IP=$(gcloud compute addresses describe $IP_NAME \
  --region=$REGION --format="get(address)")

echo "✅ IP tĩnh vừa tạo: $STATIC_IP"

# 🔍 Kiểm tra xem đã có access config chưa
HAS_ACCESS_CONFIG=$(gcloud compute instances describe $INSTANCE_NAME \
  --zone=$ZONE \
  --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

if [ -n "$HAS_ACCESS_CONFIG" ]; then
  echo "⚠️ Gỡ IP cũ..."
  gcloud compute instances delete-access-config $INSTANCE_NAME \
    --access-config-name="external-nat" \
    --zone=$ZONE
else
  echo "✅ VM chưa có IP public."
fi

# 🔗 Gán IP tĩnh
echo "🔗 Gán IP [$STATIC_IP] vào VM [$INSTANCE_NAME]..."
gcloud compute instances add-access-config $INSTANCE_NAME \
  --access-config-name="external-nat" \
  --address=$STATIC_IP \
  --zone=$ZONE

echo "🎉 Hoàn tất! VM [$INSTANCE_NAME] tại [$ZONE] dùng IP:"
echo "$STATIC_IP"
