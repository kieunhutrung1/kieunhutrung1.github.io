#!/bin/bash

file_path="/etc/lp"

# ========== MENU ==========
echo ""
echo "🌐 MENU CHÍNH:"
echo "1) Tạo Proxy & gửi API"
echo "2) Hiển thị danh sách Proxy"
read -p "👉 Nhập lựa chọn (1 hoặc 2, Enter = mặc định 1): " main_choice
main_choice=${main_choice:-1}

if [[ "$main_choice" == "2" ]]; then
  if [ -f "$file_path" ]; then
    echo ""
    echo "📄 Danh sách Proxy:"
    echo "----------------------------------------"
    IFS='&' read -ra entries <<< "$(cat "$file_path")"
    for entry in "${entries[@]}"; do
      proto=$(echo "$entry" | cut -d':' -f1)
      case "$proto" in
        socks5)
          IFS=':' read -r _ ip port user pass <<< "$entry"
          echo "🔐 SOCKS5:       $ip:$port ($user / $pass)"
          ;;
        http)
          IFS=':' read -r _ ip port user pass <<< "$entry"
          echo "🌐 HTTP:         $ip:$port ($user / $pass)"
          ;;
        shadowsocks)
          IFS=':' read -r _ ip port method pass tag <<< "$entry"
          echo "🛰️ SHADOWSOCKS:  $ip:$port $method / $pass / $tag"
          ;;
        *)
          echo "⚠️ Không xác định: $entry"
          ;;
      esac
    done
    echo "----------------------------------------"
  else
    echo "❌ Không tìm thấy file proxy."
  fi
  exit 0
fi

# ========== CẬP NHẬT ==========
read -p "👉 Cập nhật hệ thống và cài iptables + cron? (y/N): " update_ans
update_ans=${update_ans:-n}
[[ "$update_ans" =~ ^[Yy]$ ]] && sudo apt update && sudo apt-get install --no-upgrade iptables cron -y

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

# ========== GỬI API ==========
read -p "👉 Bạn có muốn gửi Proxy lên API? (y/n, Enter = y): " send_api_ans
send_api_ans=${send_api_ans:-y}

if [[ "$send_api_ans" == "y" ]]; then
  proxy_line=$(cat "$file_path")
  IFS='&' read -ra proxy_parts <<< "$proxy_line"

  socks_proxy=""
  http_proxy=""
  shadow_proxy=""
  main_ip=""

  for entry in "${proxy_parts[@]}"; do
    IFS=':' read -ra f <<< "$entry"
    proto="${f[0]}"

    if [[ "$proto" == "socks5" ]]; then
      main_ip="${f[1]}"
      socks_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}"
    elif [[ "$proto" == "http" ]]; then
      http_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}"
    elif [[ "$proto" == "shadowsocks" ]]; then
      shadow_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}"
    fi
  done

  encoded_ip=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$main_ip'''))")
  encoded_socks=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$socks_proxy'''))")
  encoded_http=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$http_proxy'''))")
  encoded_shadow=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$shadow_proxy'''))")
  encoded_server=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$server_name'''))")

  url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?IP=$encoded_ip&PROXY=$encoded_socks&HTTP=$encoded_http&SHADOW=$encoded_shadow&SEVER=$encoded_server"
  curl -s -G "$url" > /dev/null 2>&1 && echo "✅ Đã gửi proxy đến API." || echo "❌ Gửi thất bại."
fi
