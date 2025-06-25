#!/bin/bash

# Số lượng IP muốn tạo
COUNT=5  # ❗️Bạn có thể đổi số lượng tại đây

# Vùng muốn tạo IP
REGION="asia-northeast1"

echo "🚀 Đang tạo $COUNT IP tĩnh ở vùng $REGION..."

for i in $(seq 1 $COUNT); do
  NAME="ip-tokyo-$i"
  echo "👉 Tạo $NAME..."
  gcloud compute addresses create $NAME --region=$REGION
done

echo ""
echo "📋 Danh sách IP tĩnh vừa tạo:"
gcloud compute addresses list --filter="region:($REGION)" --format="table(name, address, status)"
