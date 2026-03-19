#!/bin/bash
# ===== HỎI CHUYỂN SANG ROOT =====
read -p "👉 Bạn có muốn chuyển sang quyền root (sudo -i)? (y/N): " root_choice
root_choice=${root_choice:-n}  # Mặc định là 'n' nếu người dùng nhấn Enter

if [[ "$root_choice" =~ ^[Yy]$ ]]; then
  echo "🔐 Đang chuyển sang quyền root..."
  sudo -i
  exit 0
fi
file_path="/etc/lp"



# ========== HIỂN THỊ PROXY FUNCTION ==========
show_proxy() {
  echo ""
  echo "----------------------------------------"
  echo "📄 Proxy đầy đủ:"
  cat "$file_path"
  echo "----------------------------------------"
}
create_vm_flow() {
# ❓ Cập nhật hệ thống
read -p "👉 Bạn có muốn cập nhật hệ thống và cài iptables + cron? (y/N): " update_ans
update_ans=${update_ans:-n}

if [[ "$update_ans" =~ ^[Yy]$ ]]; then
  echo "🔧 Đang cập nhật và cài đặt..."
  sudo apt update && sudo apt-get install --no-upgrade iptables cron -y
else
  echo "⏩ Bỏ qua bước cập nhật."
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
  echo ""
  echo "🌐 Gửi dòng: $proxy_line"
  # curl -s -G "$url" && echo "✅ Gửi thành công." || echo "❌ Gửi thất bại."
   curl -s -L -G "$url" > /dev/null 2>&1
done < "$file_path"

# ========== HIỂN THỊ SAU KHI GỬI ==========
# show_proxy
}
create_vm_flow() {
  zones_tokyo=("asia-northeast1-a" "asia-northeast1-b" "asia-northeast1-c")
  zones_osaka=("asia-northeast2-a" "asia-northeast2-b" "asia-northeast2-c")
echo ""
echo "🖥️ Chọn loại máy:"
echo "1) e2-micro (free tier)"
echo "2) t2d-standard-1 (AMD EPYC mạnh hơn)"
read -p "👉 Nhập lựa chọn [1-2] (mặc định: 1): " MACHINE_OPTION
MACHINE_OPTION=${MACHINE_OPTION:-1}

if [ "$MACHINE_OPTION" == "2" ]; then
  MACHINE_TYPE="t2d-standard-1"
else
  MACHINE_TYPE="e2-micro"
fi
  echo -e "\n🌏 Chọn khu vực:"
  echo "1) Tokyo (asia-northeast1)"
  echo "2) Osaka (asia-northeast2)"
  read -p "Nhập số [1-2]: " REGION_CHOICE

  case $REGION_CHOICE in
    1)
      REGION="asia-northeast1"
      ZONES=("${zones_tokyo[@]}")
      PREFIX="tokyo"
      ;;
    2)
      REGION="asia-northeast2"
      ZONES=("${zones_osaka[@]}")
      PREFIX="osaka"
      ;;
    *)
      echo "❌ Lựa chọn không hợp lệ. Thoát script."
      exit 1
      ;;
  esac

  echo -e "\n📌 Chọn zone trong vùng $REGION:"
  for i in "${!ZONES[@]}"; do
    echo "$((i+1))) ${ZONES[$i]}"
  done

  read -p "➡️ Nhập số tương ứng với zone (hoặc Enter để tạo rải đều): " ZONE_INDEX
  if [ -n "$ZONE_INDEX" ]; then
    ZONE_INDEX=$((ZONE_INDEX - 1))
    if [ "$ZONE_INDEX" -lt 0 ] || [ "$ZONE_INDEX" -ge "${#ZONES[@]}" ]; then
      echo "❌ Zone không hợp lệ. Thoát script."
      exit 1
    fi
    ZONES=("${ZONES[$ZONE_INDEX]}")
  fi

  read -p "✏️ Nhập prefix đặt tên VM (mặc định: $PREFIX): " CUSTOM_PREFIX
  PREFIX=${CUSTOM_PREFIX:-$PREFIX}

  read -p "🔢 Nhập số lượng VM muốn tạo (mặc định: 5): " COUNT
  COUNT=${COUNT:-5}

  echo "🌐 Chọn loại IP:"
  echo "1) Có IP công cộng (Public IP – sẽ gán IP tĩnh riêng)"
  echo "2) Không có IP công cộng (Private only)"
  read -p "🔌 Nhập lựa chọn [1-2] (mặc định: 1): " IP_OPTION
  IP_OPTION=${IP_OPTION:-1}

  if [ "$IP_OPTION" == "1" ]; then
    echo "📶 Chọn Network Tier cho IP:"
    echo "1) STANDARD (giá rẻ, đủ dùng) 🔹"
    echo "2) PREMIUM (ưu tiên mạng Google, giá cao hơn)"
    read -p "💡 Nhập lựa chọn [1-2] (mặc định: 1): " TIER_OPTION
    TIER_OPTION=${TIER_OPTION:-1}
    if [ "$TIER_OPTION" == "1" ]; then
      NETWORK_TIER="STANDARD"
    else
      NETWORK_TIER="PREMIUM"
    fi
  fi

  echo -e "\n🚀 Đang tạo $COUNT VM tại vùng: $REGION..."

  for ((i=1; i<=COUNT; i++)); do
    ZONE="${ZONES[((i-1)%${#ZONES[@]})]}"
    REGION=$(echo "$ZONE" | rev | cut -d'-' -f2- | rev)
    num=$(printf "%02d" $((RANDOM % 100)))
    name="${PREFIX}${num}"

    if gcloud compute instances describe "$name" --zone="$ZONE" &>/dev/null; then
      echo "⚠️ VM $name đã tồn tại ở $ZONE. Bỏ qua."
      continue
    fi

    if [ "$IP_OPTION" == "1" ]; then
      IP_NAME="ip-${name}"
      echo "⚙️ Tạo IP tĩnh [$IP_NAME] trong vùng [$REGION]..."
      if ! gcloud compute addresses create "$IP_NAME" --region="$REGION" --network-tier="$NETWORK_TIER" --quiet; then
        echo "❌ Không tạo được IP [$IP_NAME]. Có thể vượt quota. Bỏ qua VM này."
        continue
      fi
      STATIC_IP=$(gcloud compute addresses describe "$IP_NAME" --region="$REGION" --format="get(address)")
      echo "🛠️ Tạo VM [$name] ở $ZONE với IP: $STATIC_IP"
      gcloud compute instances create "$name" \
        --zone="$ZONE" \
        --machine-type="$MACHINE_TYPE" \
        --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
        --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB \
        --address="$STATIC_IP" \
        --network-tier="$NETWORK_TIER"
      echo "$name,$STATIC_IP,$ZONE" >> created_vms.log
    else
      echo "🔒 Tạo VM [$name] không có IP công cộng ở $ZONE"
      gcloud compute instances create "$name" \
        --zone="$ZONE" \
        --machine-type="$MACHINE_TYPE" \
        --image=ubuntu-minimal-2404-noble-amd64-v20250624 \
        --image-project=ubuntu-os-cloud \
        --boot-disk-size=10GB \
        --no-address
      echo "$name,NONE,$ZONE" >> created_vms.log
    fi
    echo "✅ Đã tạo: $name"
  done
}
# ========== MENU CHÍNH ==========
echo ""
echo "🌐 MENU CHÍNH:"
echo "1) Tạo Proxy và gửi API"
echo "2) Chỉ hiển thị danh sách Proxy"
echo "3) Tạo nhiều VM"
echo "4) Đổi IP VM"
echo "5) Xoá tất cả IP tĩnh không dùng (toàn bộ dự án)"
echo "6) Xoá IP khỏi 1 VM đang gán IP"
echo "7) Tạo nhiều IP tĩnh (STANDARD hoặc PREMIUM)"
read -p "👉 Nhập lựa chọn (1/2/3/4/5) (mặc định: 1): " MAIN_CHOICE
MAIN_CHOICE=${MAIN_CHOICE:-1}

case "$MAIN_CHOICE" in
  1) create_vm_flow ;;
  2) show_proxy ;;
  3) create_vm_flow ;;
  4) change_ip_flow ;;
  4) cleanup_global_ips_direct ;;
  5) remove_ip_from_vm ;;
  6) create_ip_batch ;;
  *) echo "❌ Lựa chọn không hợp lệ. Thoát."; exit 1 ;;
esac
