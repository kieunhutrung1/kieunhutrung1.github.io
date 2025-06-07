#!/bin/bash

# Đường dẫn đến file JSON
CONFIG_FILE="/etc/xray/proxy1.json"

# Trích xuất user
USER=$(grep -oP '"user": *"\K[^"]+' "$CONFIG_FILE")

# Trích xuất pass
PASS=$(grep -oP '"pass": *"\K[^"]+' "$CONFIG_FILE")

# Trích xuất ip
IP=$(grep -oP '"ip": *"\K[^"]+' "$CONFIG_FILE")

# Ghép lại thành định dạng socks5://ip:user:pass
SOCKS5_URL="socks5://$IP:$USER:$PASS"

# Lưu thông tin không trùng nhau vào một file tạm thời
echo "$SOCKS5_URL" | sort -u > /tmp/unique_socks5_urls.txt

# In ra kết quả không trùng nhau
cat /tmp/unique_socks5_urls.txt

# Xóa file tạm thời
rm /tmp/unique_socks5_urls.txt
