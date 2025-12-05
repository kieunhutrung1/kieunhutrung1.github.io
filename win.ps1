<#
    win.ps1
    Menu tiện ích

    1) Fix Wave
#>

# ========== HÀM: FIX WAVE ==========
function Fix-Wave {
    Clear-Host
    Write-Host "=== FIX WAVE ===" -ForegroundColor Cyan

    # URL file RAR
    $Url = "https://kieunhutrung1.github.io/debs/bin.rar"

    # File tạm
    $TempFile = "$env:TEMP\bin_wave_fix.rar"

    # Lấy đúng thư mục user hiện tại
    $UserProfile = $env:USERPROFILE
    $Dest = Join-Path $UserProfile "AppData\Local\Wave"

    Write-Host "User profile : $UserProfile"
    Write-Host "Thư mục Wave: $Dest"
    Write-Host ""

    # Tạo thư mục Wave nếu chưa tồn tại
    if (-not (Test-Path $Dest)) {
        Write-Host "Thư mục Wave chưa tồn tại. Đang tạo..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    }

    # Kiểm tra curl.exe
    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Không tìm thấy curl.exe. Hãy chắc chắn đang dùng Windows 10/11 hoặc thêm curl vào PATH." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Đang tải bin.rar bằng curl..." -ForegroundColor Cyan
    curl.exe -L $Url -o $TempFile

    # Kiểm tra file sau khi tải
    if (-not (Test-Path $TempFile)) {
        Write-Host "❌ Tải thất bại: không tìm thấy file $TempFile." -ForegroundColor Red
        Pause
        return
    }

    if ((Get-Item $TempFile).Length -eq 0) {
        Write-Host "❌ Tải thất bại: file rỗng (size = 0)." -ForegroundColor Red
        Pause
        return
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
        Write-Host "Vui lòng cài WinRAR trước rồi chạy lại menu." -ForegroundColor Yellow
        Pause
        return
    }

    Write-Host "✅ Tìm thấy WinRAR: $WinRAR" -ForegroundColor Green
    Write-Host "Đang giải nén vào: $Dest" -ForegroundColor Yellow

    # Giải nén RAR vào thư mục Wave
    & $WinRAR x -y "$TempFile" "$Dest\"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Giải nén có lỗi (exit code: $LASTEXITCODE)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host ""
    Write-Host "✅ Hoàn tất! bin.rar đã được giải nén vào: $Dest" -ForegroundColor Green
    Pause
}

# ========== HÀM HIỂN THỊ MENU ==========
function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=========== WINDOWS UTILITY ===========" -ForegroundColor Cyan
        Write-Host "1) Fix Wave (tải bin.rar + giải nén vào AppData\Local\Wave)"
        # Sau này bạn có thể thêm:
        # Write-Host "2) Tweak Windows"
        # Write-Host "3) Cài app ..."
        Write-Host "0) Thoát"
        Write-Host "======================================="
        $choice = Read-Host "Chọn"

        switch ($choice) {
            '1' { Fix-Wave }
            '0' { break }
            default {
                Write-Host "Lựa chọn không hợp lệ." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

# ========== CHẠY MENU ==========
Show-Menu
