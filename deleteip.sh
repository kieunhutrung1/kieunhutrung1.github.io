#!/bin/bash

REGION="asia-northeast1"

echo "🧹 Đang kiểm tra và xoá các IP tĩnh không dùng trong vùng: $REGION..."

# Lấy danh sách IP tĩnh có trạng thái RESERVED (chưa dùng)
IP_LIST=$(gcloud compute addresses list \
  --filter="status=RESERVED AND region:($REGION)" \
  --format="value(name)")

# Kiểm tra có IP nào không
if [ -z "$IP_LIST" ]; then
  echo "✅ Không có IP nào cần xoá."
  exit 0
fi

# Vòng lặp xoá từng IP
for ip in $IP_LIST; do
  echo "❌ Đang xoá IP tĩnh: $ip"
  gcloud compute addresses delete $ip --region=$REGION --quiet
done

echo "✅ Đã xoá xong tất cả IP không sử dụng."
