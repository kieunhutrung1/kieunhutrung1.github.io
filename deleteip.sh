#!/bin/bash

echo "🧹 Đang kiểm tra và xoá các IP tĩnh không dùng trong toàn bộ dự án..."

# Lấy danh sách các IP có trạng thái RESERVED (chưa sử dụng)
mapfile -t IP_ENTRIES < <(gcloud compute addresses list \
  --filter="status=RESERVED" \
  --format="value(name,region)")

# Kiểm tra danh sách rỗng
if [ ${#IP_ENTRIES[@]} -eq 0 ]; then
  echo "✅ Không có IP nào cần xoá."
  exit 0
fi

# Xoá từng IP theo cặp name + region
for entry in "${IP_ENTRIES[@]}"; do
  IP_NAME=$(echo "$entry" | awk '{print $1}')
  REGION_URL=$(echo "$entry" | awk '{print $2}')
  REGION=$(basename "$REGION_URL")  # lấy phần tên vùng từ URL

  echo "❌ Đang xoá IP [$IP_NAME] tại vùng [$REGION]..."
  gcloud compute addresses delete "$IP_NAME" --region="$REGION" --quiet
done

echo "✅ Đã xoá xong tất cả IP tĩnh không sử dụng trong toàn bộ dự án."
