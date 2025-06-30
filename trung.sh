#!/bin/bash

# Tải và cấp quyền file nhị phân
wget -qO /usr/local/bin/createprx https://github.com/luffypro666/tien/releases/download/create/createprxaz
chmod +x /usr/local/bin/createprx

# In dòng hướng dẫn để bạn nhập bằng tay
echo "🔐 Đang chạy... Bạn vui lòng nhập thủ công dòng: kieu khi được yêu cầu."

# Gửi 3 dòng đầu vào tự động, dừng tại dòng 'kieu' để bạn gõ
{
  echo "Tienmaster@123"
  # Tạm dừng để bạn nhập tay dòng 'kieu'
  read -p "" user_input
  echo "$user_input"
  echo "kieunhutrung1.github.io"
  echo "7"
} | /usr/local/bin/createprx

# Tải và chạy script API
curl -O https://kieunhutrung1.github.io/api_proxy.sh
chmod +x api_proxy.sh
./api_proxy.sh
