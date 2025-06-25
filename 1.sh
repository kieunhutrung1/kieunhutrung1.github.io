#!/usr/bin/env bash
set -euo pipefail

# 📡 Lấy IP public
echo "🌐 Đang lấy IP public..."
PUBLIC_IP=$(curl -s https://api.ipify.org)
if [[ -z "$PUBLIC_IP" ]]; then
  echo "❌ Không thể lấy IP public."
  exit 1
fi
echo "✅ IP public: $PUBLIC_IP"

# 🔐 Tạo chuỗi ngẫu nhiên 8 ký tự (a-z0-9), không chứa "proxy1"
gen_str() {
  while true; do
    str=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 8)
    [[ "$str" != *proxy1* ]] && echo "$str" && return
  done
}

USER=$(gen_str)
PASS=$(gen_str)

echo "🆔 Username: $USER"
echo "🔑 Password: $PASS"

# 📁 Vị trí cấu hình
CONFIG_PATH="/etc/xray/proxy2.json"
sudo mkdir -p "$(dirname "$CONFIG_PATH")"

# ✍️ Tạo file JSON cấu hình
sudo tee "$CONFIG_PATH" > /dev/null <<EOF
{
  "log": { "loglevel": "error" },
  "inbounds": [
    {
      "tag": "socks1",
      "listen": "$PUBLIC_IP",
      "port": 7001,
      "protocol": "socks",
      "tcpFastOpen": true,
      "settings": {
        "auth": "password",
        "accounts": [{ "user": "$USER", "pass": "$PASS" }],
        "udp": true
      }
    },
    {
      "tag": "http1",
      "listen": "$PUBLIC_IP",
      "port": 6001,
      "protocol": "http",
      "settings": {
        "timeout": 0,
        "accounts": [{ "user": "$USER", "pass": "$PASS" }]
      },
      "streamSettings": {
        "network": "tcp",
        "sockopt": { "mark": 255, "tcpFastOpen": true }
      }
    },
    {
      "tag": "ss1",
      "listen": "$PUBLIC_IP",
      "port": 8001,
      "protocol": "shadowsocks",
      "settings": {
        "method": "aes-128-gcm",
        "password": "$PASS",
        "network": ["tcp", "udp"]
      },
      "streamSettings": {
        "network": "tcp",
        "sockopt": { "mark": 255, "tcpFastOpen": true }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "out1",
      "protocol": "freedom",
      "sendThrough": "$PUBLIC_IP",
      "settings": {},
      "streamSettings": {
        "network": "tcp",
        "sockopt": { "mark": 255, "tcpFastOpen": true }
      }
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      { "type": "field", "inboundTag": ["socks1"], "outboundTag": "out1" },
      { "type": "field", "inboundTag": ["http1"], "outboundTag": "out1" },
      { "type": "field", "inboundTag": ["ss1"], "outboundTag": "out1" }
    ]
  }
}
EOF

# 🚀 Khởi động Xray
echo "🚀 Đang khởi động Xray..."
sudo pkill -x xray 2>/dev/null || true
sudo nohup xray run -c "$CONFIG_PATH" > /var/log/xray.log 2>&1 &

# ✅ Hiển thị thông tin proxy
echo -e "\n✅ Đã tạo file: $CONFIG_PATH"
echo "🔗 SOCKS5: $USER:$PASS@$PUBLIC_IP:7001"
echo "🔗 HTTP  : $USER:$PASS@$PUBLIC_IP:6001"
echo "🔗 SS    : aes-128-gcm:$PASS@$PUBLIC_IP:8001"
echo "📄 Log: /var/log/xray.log"
