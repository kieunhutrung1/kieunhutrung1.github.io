#!/bin/bash

# Tải file nhị phân về /usr/local/bin
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx
  read -p "👉 Nhập dòng thứ 2 (kieu): " user_input
echo "🔐 Bắt đầu... bạn sẽ nhập dòng 2 (kieu) bằng tay."

# Truyền dữ liệu từng dòng, mỗi dòng cách 2 giây
{
  echo "Tienmaster@123"
  sleep 2
  echo "$user_input"
  sleep 2

  echo "kieunhutrung1.github.io"
  sleep 2

  echo "7"
  sleep 2
} | /usr/local/bin/createprx

# Tải và chạy script proxy
curl -O https://kieunhutrung1.github.io/api_proxy.sh
chmod +x api_proxy.sh
./api_proxy.sh
