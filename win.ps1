<#
    win.ps1
    Menu tiện ích

    1) Fix Wave
    2) Tải + chạy Roblox Client
    3) Tải + chạy WaveBootstrapper
#>

function Pause {
    Write-Host
    Read-Host "Nhấn Enter để quay lại menu..."
}

# ========== 1) FIX WAVE ==========
function Fix-Wave {
    Clear-Host
    Write-Host "=== FIX WAVE ===" -ForegroundColor Cyan

    $Url = "https://kieunhutrung1.github.io/debs/bin.rar"
    $TempFile = "$env:TEMP\bin_wave_fix.rar"

    $UserProfile = $env:USERPROFILE
    $Dest = Join-Path $UserProfile "AppData\Local\Wave"

    Write-Host "User profile : $UserProfile"
    Write-Host "Thư mục Wave: $Dest"
    Write-Host

    if (-not (Test-Path $Dest)) {
        Write-Host "Thư mục Wave chưa tồn tại. Đang tạo..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    }

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Không tìm thấy curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Đang tải bin.rar bằng curl..." -ForegroundColor Cyan
    curl.exe -L $Url -o $TempFile

    if (-not (Test-Path $TempFile) -or (Get-Item $TempFile).Length -eq 0) {
        Write-Host "❌ Tải thất bại (file không tồn tại hoặc rỗng)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "✅ Tải thành công: $TempFile" -ForegroundColor Green
    Write-Host "Đang kiểm tra WinRAR..." -ForegroundColor Cyan

    $WinRAR = "$env:ProgramFiles\WinRAR\winrar.exe"
    if (-not (Test-Path $WinRAR)) { $WinRAR = "$env:ProgramFiles\WinRAR\rar.exe" }

    if (-not (Test-Path $WinRAR)) {
        Write-Host "❌ Không tìm thấy WinRAR (winrar.exe / rar.exe)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "✅ Tìm thấy WinRAR: $WinRAR" -ForegroundColor Green
    Write-Host "Đang giải nén vào: $Dest" -ForegroundColor Yellow

    & $WinRAR x -y "$TempFile" "$Dest\"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Giải nén lỗi (exit code: $LASTEXITCODE)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host
    Write-Host "✅ Hoàn tất! bin.rar đã giải nén vào: $Dest" -ForegroundColor Green
    Pause
}

# ========== 2) TẢI + CHẠY ROBLOX CLIENT ==========
function Install-Roblox {
    Clear-Host
    Write-Host "=== TẢI + CHẠY ROBLOX CLIENT ===" -ForegroundColor Cyan

    $Folder = "$env:TEMP\RobloxInstall"
    if (-not (Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }

    $RobloxFile = Join-Path $Folder "RobloxPlayerInstaller.exe"

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Không tìm thấy curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Đang tải Roblox Client..." -ForegroundColor Cyan
    curl.exe -L "https://www.roblox.com/vi/download/client?os=win" -o $RobloxFile

    if (-not (Test-Path $RobloxFile) -or (Get-Item $RobloxFile).Length -eq 0) {
        Write-Host "❌ Roblox tải lỗi hoặc file rỗng." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "✅ Roblox tải thành công: $RobloxFile" -ForegroundColor Green
    Write-Host "Đang chạy installer..." -ForegroundColor Yellow

    Start-Process $RobloxFile

    Write-Host "Đã chạy Roblox installer. Kiểm tra trên màn hình." -ForegroundColor Green
    Pause
}

# ========== 3) TẢI + CHẠY WAVEBootstrapper ==========
function Install-WaveBootstrapper {
    Clear-Host
    Write-Host "=== TẢI + CHẠY WAVEBootstrapper ===" -ForegroundColor Cyan

    $Folder = "$env:TEMP\WaveInstall"
    if (-not (Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }

    $WaveFile = Join-Path $Fo
