#!/bin/bash

file_path="/etc/lp"

send_api() {
    # Tạm comment dòng này khi test để nhìn thấy lỗi
    # exec >/dev/null 2>&1

    if [ ! -f "$file_path" ]; then
        echo "Không tìm thấy $file_path"
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

        echo "$url"
    done < "$file_path"
}

send_api
