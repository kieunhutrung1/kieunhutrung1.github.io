#!/bin/bash

# Lấy địa chỉ IP
IP=$(grep -oP '"listen": "\K[0-9.]+(?=")' /etc/xray/proxy1.json)

# Lấy thông tin user và pass
USER=$(grep -A2 '"accounts":' /etc/xray/proxy1.json | grep -E '"user":' | sed 's/[",]//g' | awk '{print $2}')
PASS=$(grep -A2 '"accounts":' /etc/xray/proxy1.json | grep -E '"pass":' | sed 's/[",]//g' | awk '{print $2}')

# Ghép lại với nhau
RESULT="socks5://$IP:$USER:$PASS"

# In kết quả
echo $RESULT
