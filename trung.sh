
#!/bin/bash
file_path="/etc/lp"

# ========================== MENU BAN ĐẦU ==========================
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
    cat "$file_path"
    echo "----------------------------------------"
  else
    echo "❌ Không tìm thấy danh sách Proxy."
  fi
  exit 0
fi

# ========================== CẬP NHẬT ==========================
read -p "👉 Cập nhật hệ thống và cài iptables + cron? (y/N): " update_ans
update_ans=${update_ans:-n}
[[ "$update_ans" =~ ^[Yy]$ ]] && sudo apt update && sudo apt-get install --no-upgrade iptables cron -y

# ========================== NHẬP TÊN SERVER ==========================
read -p "👉 Nhập Tên SEVER: " user_input

# ========================== HỎI GỬI API ==========================
read -p "👉 Sau khi tạo proxy, bạn có muốn gửi Proxy lên API? (y/n, Enter = y): " send_api_ans
send_api_ans=${send_api_ans:-y}

if [[ "$send_api_ans" == "y" ]]; then
  echo ""
  echo "🛠️ Chọn cách gửi API:"
  echo "1) Gửi tách từng loại proxy (cũ)"
  echo "2) Gửi toàn bộ nội dung file (mới)"
  while true; do
    read -p "👉 Nhập lựa chọn (1 hoặc 2, Enter = 2): " api_mode
    api_mode=${api_mode:-2}
    if [[ "$api_mode" == "1" || "$api_mode" == "2" ]]; then
      break
    else
      echo "❌ Vui lòng chỉ nhập 1 hoặc 2."
    fi
  done
fi

# ========================== TẠO PROXY ==========================
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx
{
  echo "Tienmaster@123"
  echo "$user_input"
  echo "kieunhutrung1.github.io"
  sleep 2
  echo "7"
  sleep 2
} | /usr/local/bin/createprx

# ========================== GỬI API ==========================
if [[ "$send_api_ans" == "y" ]]; then
  if [[ "$api_mode" == "1" ]]; then
    # ==== GỬI KIỂU CŨ ====
    socks_proxy=""
    http_proxy=""
    shadow_proxy=""
    main_ip=""
    server_name="$user_input"

    while IFS= read -r line; do
      IFS=':' read -ra parts <<< "$line"
      type="${parts[-1]}"
      if [[ "$type" == "socks" ]]; then
        socks_proxy="${parts[0]}:${parts[1]}:${parts[2]}:${parts[3]}"
        [[ -z "$main_ip" ]] && main_ip="${parts[0]}"
      elif [[ "$type" == "http" ]]; then
        http_proxy="${parts[0]}:${parts[1]}:${parts[2]}:${parts[3]}"
        [[ -z "$main_ip" ]] && main_ip="${parts[0]}"
      elif [[ "$type" == "shadowsocks" ]]; then
        shadow_proxy="${parts[0]}:${parts[1]}:${parts[2]}:${parts[3]}"
        [[ -z "$main_ip" ]] && main_ip="${parts[0]}"
      fi
    done < "$file_path"

    encoded_ip=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$main_ip'''))")
    encoded_socks=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$socks_proxy'''))")
    encoded_http=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$http_proxy'''))")
    encoded_shadow=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$shadow_proxy'''))")
    encoded_server=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$server_name'''))")

    url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?IP=$encoded_ip&PROXY=$encoded_socks&HTTP=$encoded_http&SHADOW=$encoded_shadow&SEVER=$encoded_server"
    curl -s -G "$url" > /dev/null 2>&1
    echo "✅ Đã gửi proxy theo kiểu cũ (phân loại)."

  elif [[ "$api_mode" == "2" ]]; then
    # ==== GỬI KIỂU MỚI ====
    if [ -f "$file_path" ]; then
      first_line=$(head -n 1 "$file_path")
      main_ip=$(echo "$first_line" | cut -d':' -f1)
      raw_proxy=$(cat "$file_path")

      encoded_ip=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$main_ip'''))")
      encoded_proxy=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$raw_proxy'''))")

      url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?IP=$encoded_ip&PROXY=$encoded_proxy"
      curl -s -G "$url" > /dev/null 2>&1
      echo "✅ Đã gửi toàn bộ nội dung proxy theo kiểu mới."
    else
      echo "❌ Không tìm thấy file để gửi."
    fi
  fi
fi

# ========================== HIỂN THỊ DANH SÁCH ==========================
if [ -f "$file_path" ]; then
  echo ""
  echo "📄 Danh sách Proxy:"
  echo "----------------------------------------"
  while IFS= read -r line; do
    IFS=':' read -r ip port val3 val4 type <<< "$line"
    case "$type" in
      socks)
        echo "🔐 SOCKS5:       $ip:$port ($val3 / $val4)"
        ;;
      http)
        echo "🌐 HTTP:         $ip:$port ($val3 / $val4)"
        ;;
      shadowsocks)
        echo "🛰️ SHADOWSOCKS:  $ip:$port $val3 / $val4"
        ;;
      *)
        echo "⚠️ Không xác định TYPE trong dòng: $line"
        ;;
    esac
  done < "$file_path"
  echo "----------------------------------------"
else
  echo "⚠️ Không tìm thấy danh sách Proxy."
fi
