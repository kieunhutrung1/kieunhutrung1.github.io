#!/bin/bash
read -p "👉 Bạn có muốn cập nhật hệ thống và cài iptables + cron? (y/n): " update_ans
if [[ "$update_ans" =~ ^[Yy]$ ]]; then
  echo "🔧 Đang cập nhật và cài đặt..."
  sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
else
  echo "⏩ Bỏ qua bước cập nhật."
fi
read -p "👉 Nhập Tên SEVER: " user_input
read -p "1) iOS 1440 generic tunnel or VPN(4G-5G)
2) iOS 1450 generic tunnel or VPN(4G-5G)
3) iOS 1492 PPPoE(wifi)
4) Android 1440 generic tunnel or VPN(4G-5G)
5) Android 1450 generic tunnel or VPN(4G-5G)
6) Android 1492 PPPoE(wifi)
7) macOS 1492 PPPoE(wifi)
8) Windows 1492 PPPoE(wifi)
9) Windows 1440 generic tunnel or VPN(4G-5G)
👉 Chọn cấu hình TCP/IP :" user_input1
# Tải file nhị phân về /usr/local/bin
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx

# Truyền dữ liệu vào createprx (dòng 2 bạn nhập tay), cách nhau 2 giây
{
  echo "Tienmaster@123"
  echo "$user_input"
  echo "kieunhutrung1.github.io"
  sleep 2

  echo "$user_input1"
  sleep 2
} | /usr/local/bin/createprx

# Sau khi chạy xong, tải và chạy script API proxy
curl -O https://kieunhutrung1.github.io/api_proxy.sh
chmod +x api_proxy.sh
./api_proxy.sh
