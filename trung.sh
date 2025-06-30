#!/bin/bash

# ❓ Hỏi trước khi cập nhật hệ thống
read -p "👉 Bạn có muốn cập nhật hệ thống và cài iptables + cron? (y/n): " update_ans
if [[ "$update_ans" =~ ^[Yy]$ ]]; then
  echo "🔧 Đang cập nhật và cài đặt..."
  sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
else
  echo "⏩ Bỏ qua bước cập nhật."
fi

# ❓ Hỏi trước khi tải và cài đặt file nhị phân
read -p "👉 Bạn có muốn tải và cài đặt file nhị phân createprx? (y/n): " bin_ans
if [[ "$bin_ans" =~ ^[Yy]$ ]]; then
  echo "⬇️ Đang tải và cấp quyền..."
 wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz && chmod +x /usr/local/bin/createprx && /usr/local/bin/createprx && curl -O https://kieunhutrung1.github.io/api_proxy.sh && chmod +x api_proxy.sh && ./api_proxy.sh
else
  echo "❌ Bạn đã chọn không cài file nhị phân. Thoát script."
  exit 0
fi

# Truyền dữ liệu từng dòng, mỗi dòng cách 2 giây
{
  echo "Tienmaster@123"
} | /usr/local/bin/createprx
