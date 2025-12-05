<# 
    wave_bin_install.ps1
    - Tải bin.rar bằng curl.exe
    - Giải nén vào %USERPROFILE%\AppData\Local\Wave
#>

# URL file RAR cần tải
$Url = "https://kieunhutrung1.github.io/debs/bin.rar"

# File tạm để lưu RAR
$TempFile = "$env:TEMP\bin.rar"

# Lấy đúng thư mục user hiện tại
$UserProfile = $env:USERPROFILE

# Thư mục Wave đích
$Dest = Join-Path $UserProfile "AppData\Local\Wave"

Write-Host "User profile: $UserProfile" -ForegroundColor Cyan
Write-Host "Thư mục đích: $Dest" -ForegroundColor Cyan

# Tạo thư mục Wave nếu chưa có
if (-not (Test-Path $Dest)) {
    Write-Host "Thư mục Wave chưa tồn tại. Đang tạo..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
}

# Kiểm tra curl.exe
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Không tìm thấy curl.exe. Hãy chắc chắn bạn đang dùng Windows 10/11 hoặc thêm curl vào PATH." -ForegroundColor Red
    exit 1
}

Write-Host "Đang tải bin.rar bằng curl..." -ForegroundColor Cyan

# Tải file bằng curl.exe
curl.exe -L $Url -o $TempFile

# Kiểm tra file sau khi tải
if (-not (Test-Path $TempFile)) {
    Write-Host "❌ Tải thất bại: không tìm thấy file $TempFile." -ForegroundColor Red
    exit 1
}

if ((Get-Item $TempFile).Length -eq 0) {
    Write-Host "❌ Tải thất bại: file rỗng (size = 0)." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Tải thành công: $TempFile" -ForegroundColor Green
Write-Host "Đang kiểm tra WinRAR..." -ForegroundColor Cyan

# Tìm WinRAR
$WinRAR = "$env:ProgramFiles\WinRAR\winrar.exe"
if (-not (Test-Path $WinRAR)) { 
    $WinRAR = "$env:ProgramFiles\WinRAR\rar.exe"
}

if (-not (Test-Path $WinRAR)) {
    Write-Host "❌ Không tìm thấy WinRAR (winrar.exe / rar.exe trong Program Files)." -ForegroundColor Red
    Write-Host "Vui lòng cài WinRAR trước rồi chạy lại script." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Tìm thấy WinRAR: $WinRAR" -ForegroundColor Green
Write-Host "Đang giải nén vào: $Dest" -ForegroundColor Yellow

# Giải nén RAR vào thư mục Wave
& $WinRAR x -y "$TempFile" "$Dest\"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Giải nén có lỗi (exit code: $LASTEXITCODE)." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "✅ Hoàn tất! bin.rar đã được giải nén vào: $Dest" -ForegroundColor Green
