if [[ "$send_api_ans" == "y" ]]; then
  if [ "$api_mode" == "1" ]; then
    # ==== KIỂU GỬI CŨ: Gửi từng loại proxy riêng biệt ====
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

    # Encode và gửi
    encoded_ip=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$main_ip'''))")
    encoded_socks=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$socks_proxy'''))")
    encoded_http=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$http_proxy'''))")
    encoded_shadow=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$shadow_proxy'''))")
    encoded_server=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$server_name'''))")

    url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?IP=$encoded_ip&PROXY=$encoded_socks&HTTP=$encoded_http&SHADOW=$encoded_shadow&SEVER=$encoded_server"
    curl -s -G "$url" > /dev/null 2>&1
    echo "✅ Đã gửi proxy theo kiểu cũ (phân loại)."

  elif [ "$api_mode" == "2" ]; then
    # ==== KIỂU GỬI MỚI: Gửi toàn bộ nội dung file ====
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
