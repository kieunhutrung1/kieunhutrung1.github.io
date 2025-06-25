#!/bin/bash

# 📋 Lấy danh sách tất cả VM trong dự án
echo "📦 Lấy danh sách VM..."
INSTANCES=($(gcloud compute instances list --format="value(name)"))

# Kiểm tra có VM không
if [ ${#INSTANCES[@]} -eq 0 ]; then
  echo "❌ Không tìm thấy VM nào trong dự án."
  exit 1
fi

# 👇 Hiển thị menu chọn VM
echo "💻 Chọn VM để gán IP:"
select INSTANCE_NAME in "${INSTANCES[@]}"; do
  if [ -n "$INSTANCE_NAME" ]; then
    break
  else
    echo "❗ Vui lòng chọn số hợp lệ."
  fi
done

# 🔍 Tìm zone và region tương ứng
ZONE=$(gcloud compute instances list \
  --filter="name=($INSTANCE_NAME)" \
  --format="value(zone)" | rev | cut -d'/' -f1 | rev)

REGION=$(echo "$ZONE" | rev | cut -d'-' -f2- | rev)

echo "📍 VM [$INSTANCE_NAME] nằm ở ZONE: $ZONE | REGION: $REGION"

# 🚀 Tạo IP tĩnh
IP_NAME="static-ip-$RANDOM"
echo "⚙️ Tạo IP tĩnh [$IP_NAME] trong $REGION..."
gcloud compute addresses create $IP_NAME --region=$REGION

STATIC_IP=$(gcloud compute addresses describe $IP_NAME \
  --region=$REGION --format="get(address)")

echo "✅ IP tĩnh vừa tạo: $STATIC_IP"

# 🔎 Kiểm tra access config cũ
HAS_ACCESS_CONFIG=$(gcloud compute instances describe $INSTANCE_NAME \
  --zone=$ZONE \
  --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

if [ -n "$HAS_ACCESS_CONFIG" ]; then
  echo "⚠️ Gỡ IP cũ khỏi [$INSTANCE_NAME]..."
  gcloud compute instances delete-access-config $INSTANCE_NAME \
    --access-config-name="external-nat" \
    --zone=$ZONE
else
  echo "✅ VM chưa có IP public."
fi

# 🔗 Gán IP mới
echo "🔗 Gán IP [$STATIC_IP] vào [$INSTANCE_NAME]..."
gcloud compute instances add-access-config $INSTANCE_NAME \
  --access-config-name="external-nat" \
  --address=$STATIC_IP \
  --zone=$ZONE

echo "🎉 HOÀN TẤT! [$INSTANCE_NAME] đang dùng IP:"
echo "$STATIC_IP"
