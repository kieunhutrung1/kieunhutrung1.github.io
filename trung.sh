#!/bin/bash

# Tải file nhị phân về /usr/local/bin
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx
read -p "👉 Nhập tên sever: " user_input
# Truyền dữ liệu từng dòng, mỗi dòng cách 2 giây
{
  echo "Tienmaster@123"
  echo "$user_input"
  echo "kieunhutrung1.github.io"
   sleep 3
  echo "7"
} | /usr/local/bin/createprx
# Tải và chạy script proxy
curl -O https://kieunhutrung1.github.io/api_proxy.sh
chmod +x api_proxy.sh
./api_proxy.sh
