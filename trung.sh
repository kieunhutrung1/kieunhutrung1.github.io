#!/bin/bash
sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
# Tải file nhị phân về /usr/local/bin
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz && chmod +x /usr/local/bin/createprx && /usr/local/bin/createprx && curl -O https://kieunhutrung1.github.io/api_proxy.sh && chmod +x api_proxy.sh && ./api_proxy.sh
# Truyền dữ liệu từng dòng, mỗi dòng cách 2 giây
{
  echo "Tienmaster@123"
} | /usr/local/bin/createprx
