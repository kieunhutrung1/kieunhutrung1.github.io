#!/bin/bash

# =================== ĐƯỜNG DẪN FILE ===================
file_path="/etc/lp"

# =================== KIỂM TRA FILE ===================
if [ ! -f "$file_path" ]; then
  echo "❌ File không tồn tại: $file_path"
  exit 1
fi

data=$(cat "$file_path")

if [ -z "$data" ]; then
  echo "⚠️ File rỗng. Không có gì để xử lý."
  exit 1
fi

# =================== MENU LỰA CHỌN HỢP LỆ ===================
while true; do
  echo -e "\n🛠️  Bạn muốn làm gì?"
  echo "1) Gửi nội dung /etc/lp đến API và hiển thị"
  echo "2) Chỉ hiển thị nội dung /etc/lp (không gửi)"
  read -p "👉 Nhập lựa chọn (1 hoặc 2): " choice

  if [[ "$choice" == "1" || "$choice" == "2" ]]; then
    break
  else
    echo "⚠️ Vui lòng chỉ nhập 1 hoặc 2."
  fi
done

# =================== XỬ LÝ TÙY CHỌN ===================
if [ "$choice" == "1" ]; then
  echo "📡 Đang gửi nội dung đến API..."

  # Mã hóa nội dung
  encoded_data=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$data'''))")

  # URL API
  url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?PROXY=$encoded_data"

  # Gửi GET request
  curl -s -G "$url" > /dev/null 2>&1

  echo "✅ Đã gửi nội dung đến API."
fi

# =================== IN NỘI DUNG FILE ===================
echo -e "\n📄 Nội dung file /etc/lp:"
echo "------------------------------------"
echo "$data"
echo "------------------------------------"
