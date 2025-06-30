#!/bin/bash
read -p "👉 Nhập dòng thứ 2 (kieu): " user_input
# Tải file nhị phân về /usr/local/bin
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx

# Truyền dữ liệu vào createprx (dòng 2 bạn nhập tay), cách nhau 2 giây
{
  echo "Tienmaster@123"
  echo "$user_input"
  echo "kieunhutrung1.github.io"
  sleep 2

  echo "7"
  sleep 2
} | /usr/local/bin/createprx

# Sau khi chạy xong, tải và chạy script API proxy
curl -O https://kieunhutrung1.github.io/api_proxy.sh
chmod +x api_proxy.sh
./api_proxy.sh
