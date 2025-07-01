#!/bin/bash

file_path="/etc/lp"

# ========== MENU CHÍNH ==========
echo ""
echo "🌐 MENU CHÍNH:"
echo "1) Tạo Proxy và gửi API"
echo "2) Chỉ hiển thị danh sách Proxy"
read -p "👉 Nhập lựa chọn (1 hoặc 2, Enter = mặc định 1): " main_choice
main_choice=${main_choice:-1}

# ========== HIỂN THỊ PROXY FUNCTION ==========
show_proxy() {
  echo ""
  echo "----------------------------------------"
  echo "📄 Proxy đầy đủ:"
  cat "$file_path"
  echo "----------------------------------------"
}

# ========== TÙY CHỌN CHỈ HIỂN THỊ ==========
if [[ "$main_choice" == "2" ]]; then
  if [ -f "$file_path" ]; then
    show_proxy
  else
    echo "❌ Không tìm thấy file proxy."
  fi
  exit 0
fi

# ========== NHẬP TÊN SERVER ==========
read -p "👉 Nhập Tên SEVER: " server_name

# ========== CHỌN CẤU HÌNH ==========
echo ""
echo "📡 Cấu hình TCP/IP:"
echo "1) iOS 1440 generic tunnel or VPN (4G-5G)"
echo "2) iOS 1450 generic tunnel or VPN (4G-5G)"
echo "3) iOS 1492 PPPoE (wifi)"
echo "4) Android 1440 generic tunnel or VPN (4G-5G)"
echo "5) Android 1450 generic tunnel or VPN (4G-5G)"
echo "6) Android 1492 PPPoE (wifi)"
echo "7) macOS 1492 PPPoE (wifi)"
echo "8) Windows 1492 PPPoE (wifi)"
echo "9) Windows 1440 generic tunnel or VPN (4G-5G)"

while true; do
  read -p "👉 Chọn cấu hình TCP/IP (1-9, Enter = mặc định 7): " config_option
  config_option=${config_option:-7}
  [[ "$config_option" =~ ^[1-9]$ ]] && break
  echo "❌ Vui lòng nhập số 1–9."
done

# ========== TẠO PROXY ==========
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx

{
  echo "Tienmaster@123"
  echo "$server_name"
  echo "kieunhutrung1.github.io"
  sleep 2
  echo "$config_option"
  sleep 2
} | /usr/local/bin/createprx

# ========== GỬI API CHO TỪNG DÒNG ==========
if [ ! -f "$file_path" ]; then
  echo "❌ Không tìm thấy file $file_path"
  exit 1
fi

while IFS= read -r proxy_line; do
  IFS='&' read -ra proxy_parts <<< "$proxy_line"

  socks_proxy=""
  http_proxy=""
  shadow_proxy=""
  main_ip=""
  server_tag=""

  for entry in "${proxy_parts[@]}"; do
    IFS=':' read -ra f <<< "$entry"
    proto="${f[0]}"
    ip="${f[1]}"
    [[ -z "$main_ip" && "$proto" == "socks5" ]] && main_ip="$ip"

    case "$proto" in
      socks5)
        socks_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}:socks"
        ;;
      http)
        http_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}:http"
        ;;
      shadowsocks)
        shadow_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}:shadowsocks"
        server_tag="${f[5]}"
        ;;
    esac
  done

  encoded_ip=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$main_ip'''))")
  encoded_socks=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$socks_proxy'''))")
  encoded_http=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$http_proxy'''))")
  encoded_shadow=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$shadow_proxy'''))")
  encoded_server=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$server_tag'''))")
  encoded_full=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$proxy_line'''))")

  url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?IP=$encoded_ip&PROXY=$encoded_socks&HTTP=$encoded_http&SHADOW=$encoded_shadow&SEVER=$encoded_server&FULL=$encoded_full"

  echo "🌐 Gửi dòng: $proxy_line"
  curl -s -G "$url" && echo "✅ Gửi thành công." || echo "❌ Gửi thất bại."
done < "$file_path"

# ========== HIỂN THỊ SAU KHI GỬI ==========
show_proxy
