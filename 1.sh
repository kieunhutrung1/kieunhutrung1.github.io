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

# 🔐 Sinh user/pass ngẫu nhiên 8 ký tự (a-z0-9)
gen_str() {
  tr -dc 'a-z0-9' </dev/urandom | head -c 8
}
USER=$(gen_str)
PASS=$(gen_str)

echo "🆔 Username: $USER"
echo "🔑 Password: $PASS"

# 📁 Vị trí lưu file
CONFIG_PATH="/etc/xray/proxy1.json"
mkdir -p "$(dirname "$CONFIG_PATH")"

# ✍️ Ghi file cấu hình
cat > "$CONFIG_PATH" <<EOF
{
  "log": {
    "loglevel": "error"
  },
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
        "sockopt": {
          "mark": 255,
          "tcpFastOpen": true
        }
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
        "sockopt": {
          "mark": 255,
          "tcpFastOpen": true
        }
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
        "sockopt": {
          "mark": 255,
          "tcpFastOpen": true
        }
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

# ✅ Xuất thông tin
echo -e "\n✅ File đã tạo: $CONFIG_PATH"
echo "🔗 SOCKS5: $USER:$PASS@$PUBLIC_IP:7001"
echo "🔗 HTTP  : $USER:$PASS@$PUBLIC_IP:6001"
echo "🔗 SS    : aes-128-gcm:$PASS@$PUBLIC_IP:8001"
