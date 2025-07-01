#!/bin/bash

# ========================== MENU BAN ĐẦU ==========================
while true; do
  echo ""
  echo "🌐 MENU CHÍNH:"
  echo "1) Tạo Proxy & gửi API"
  echo "2) Hiển thị danh sách Proxy"
  read -p "👉 Nhập lựa chọn (1 hoặc 2, Enter = mặc định 1): " main_choice
  main_choice=${main_choice:-1}

  if [[ "$main_choice" == "1" || "$main_choice" == "2" ]]; then
    break
  else
    echo "❌ Vui lòng chỉ nhập 1 hoặc 2."
  fi
done

file_path="/etc/lp"

# ========================== CHỈ HIỂN THỊ PROXY ==========================
if [[ "$main_choice" == "2" ]]; then
  if [ -f "$file_path" ]; then
    echo ""
    echo "📄 Danh sách Proxy:"
    echo "----------------------------------------"
    cat "$file_path"
    echo "----------------------------------------"
  else
    echo "❌ Không tìm thấy danh sách Proxy."
  fi
  exit 0
fi

# ========================== CHẠY TOÀN BỘ ==========================
# ❓ Cập nhật hệ thống
read -p "👉 Bạn có muốn cập nhật hệ thống và cài iptables + cron? (y/N): " update_ans
update_ans=${update_ans:-n}

if [[ "$update_ans" =~ ^[Yy]$ ]]; then
  echo "🔧 Đang cập nhật và cài đặt..."
  sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
else
  echo "⏩ Bỏ qua bước cập nhật."
fi

# ❓ Gửi API hay không? (Enter = y)
while true; do
  read -p "👉 Sau khi tạo proxy, bạn có muốn gửi danh sách Proxy lên API? (y/n, Enter = y): " send_api_ans
  send_api_ans=${send_api_ans:-y}
  if [[ "$send_api_ans" == "y" || "$send_api_ans" == "n" ]]; then
    break
  else
    echo "❌ Vui lòng chỉ nhập y hoặc n."
  fi
done

# 📥 Nhập tên server
read -p "👉 Nhập Tên SEVER: " user_input

# 📶 Hiển thị cấu hình TCP/IP
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

# 🔁 Nhập cấu hình
while true; do
  read -p "👉 Chọn cấu hình TCP/IP (1-9, Enter = mặc định 7): " config_option
  config_option=${config_option:-7}
  if [[ "$config_option" =~ ^[1-9]$ ]]; then
    break
  else
    echo "❌ Lựa chọn không hợp lệ. Vui lòng nhập số từ 1 đến 9."
  fi
done

# ⚙️ Tải và chạy createprx
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx

{
  echo "Tienmaster@123"
  echo "$user_input"
  echo "kieunhutrung1.github.io"
  sleep 2
  echo "$config_option"
  sleep 2
} | /usr/local/bin/createprx

# ========================== GỬI API (nếu có) ==========================
if [[ "$send_api_ans" == "y" ]]; then
  if [ -f "$file_path" ]; then
    data=$(cat "$file_path")
    if [ -n "$data" ]; then
      encoded_data=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$data'''))")
      url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?PROXY=$encoded_data"
      curl -s -G "$url" > /dev/null 2>&1
      echo "✅ Đã gửi danh sách Proxy lên API."

      echo ""
      echo "📄 Danh sách Proxy:"
      echo "----------------------------------------"
      echo "$data"
      echo "----------------------------------------"
      exit 0
    else
      echo "⚠️ Danh sách Proxy trống, không có gì để gửi."
      exit 1
    fi
  else
    echo "❌ Không tìm thấy danh sách Proxy để gửi."
    exit 1
  fi
fi

# ========================== HIỂN THỊ NẾU KHÔNG GỬI ==========================
if [ -f "$file_path" ]; then
  echo ""
  echo "📄 Danh sách Proxy:"
  echo "----------------------------------------"
  cat "$file_path"
  echo "----------------------------------------"
else
  echo "⚠️ Không thể hiển thị: Danh sách Proxy không tồn tại."
fi
