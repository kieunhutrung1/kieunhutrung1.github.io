<#
    win.ps1 - Windows Utility Menu

    1) Fix Wave  (tai bin.rar + giai nen vao %USERPROFILE%\AppData\Local\Wave)
    2) Tai + chay Roblox Client
    3) Tai + chay WaveBootstrapper
    4) Tai + chay Fishstrap
    5) Tai + cai UltraViewer
#>

function Pause {
    Write-Host
    Read-Host "Nhan Enter de quay lai menu..."
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
    Write-Host "Thu muc Wave: $Dest"
    Write-Host

    if (-not (Test-Path $Dest)) {
        Write-Host "Thu muc Wave chua ton tai. Dang tao..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    }

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Dang tai bin.rar bang curl..." -ForegroundColor Cyan
    curl.exe -L $Url -o $TempFile

    if (-not (Test-Path $TempFile) -or (Get-Item $TempFile).Length -eq 0) {
        Write-Host "Tai that bai (file khong ton tai hoac rong)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Tai thanh cong: $TempFile" -ForegroundColor Green
    Write-Host "Dang kiem tra WinRAR..." -ForegroundColor Cyan

    $WinRAR = "$env:ProgramFiles\WinRAR\winrar.exe"
    if (-not (Test-Path $WinRAR)) {
        $WinRAR = "$env:ProgramFiles\WinRAR\rar.exe"
    }

    if (-not (Test-Path $WinRAR)) {
        Write-Host "Khong tim thay WinRAR (winrar.exe / rar.exe)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Tim thay WinRAR: $WinRAR" -ForegroundColor Green
    Write-Host "Dang giai nen vao: $Dest" -ForegroundColor Yellow

    & $WinRAR x -y "$TempFile" "$Dest\"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Giai nen loi (exit code: $LASTEXITCODE)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host
    Write-Host "Hoan tat! bin.rar da giai nen vao: $Dest" -ForegroundColor Green
    Pause
}

# ========== 2) TAI + CHAY ROBLOX CLIENT ==========
function Install-Roblox {
    Clear-Host
    Write-Host "=== TAI + CHAY ROBLOX CLIENT ===" -ForegroundColor Cyan

    $Folder = "$env:TEMP\RobloxInstall"
    if (-not (Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder | Out-Null
    }

    $RobloxFile = Join-Path $Folder "RobloxPlayerInstaller.exe"

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Dang tai Roblox Client..." -ForegroundColor Cyan
    curl.exe -L "https://www.roblox.com/vi/download/client?os=win" -o $RobloxFile

    if (-not (Test-Path $RobloxFile) -or (Get-Item $RobloxFile).Length -eq 0) {
        Write-Host "Roblox tai loi hoac file rong." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Roblox tai thanh cong: $RobloxFile" -ForegroundColor Green
    Write-Host "Dang chay installer..." -ForegroundColor Yellow

    Start-Process $RobloxFile

    Write-Host "Da chay Roblox installer. Kiem tra tren man hinh." -ForegroundColor Green
    Pause
}

# ========== 3) TAI + CHAY WAVEBootstrapper ==========
function Install-WaveBootstrapper {
    Clear-Host
    Write-Host "=== TAI + CHAY WAVEBootstrapper ===" -ForegroundColor Cyan

    $Folder = "$env:TEMP\WaveInstall"
    if (-not (Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder | Out-Null
    }

    $WaveFile = Join-Path $Folder "WaveBootstrapper.exe"

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Dang tai WaveBootstrapper..." -ForegroundColor Cyan
    curl.exe -L "https://cdn.wavify.cc/v3/WaveBootstrapper.exe" -o $WaveFile

    if (-not (Test-Path $WaveFile) -or (Get-Item $WaveFile).Length -eq 0) {
        Write-Host "WaveBootstrapper tai loi hoac file rong." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "WaveBootstrapper tai thanh cong: $WaveFile" -ForegroundColor Green
    Write-Host "Dang chay WaveBootstrapper..." -ForegroundColor Yellow

    Start-Process $WaveFile

    Write-Host "Da chay WaveBootstrapper. Kiem tra tren man hinh." -ForegroundColor Green
    Pause
}

# ========== 4) TAI + CHAY FISHSTRAP ==========
function Install-Fishstrap {
    Clear-Host
    Write-Host "=== TAI + CHAY FISHSTRAP ===" -ForegroundColor Cyan

    $Folder = "$env:TEMP\FishstrapInstall"
    if (-not (Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder | Out-Null
    }

    $File = Join-Path $Folder "Fishstrap.exe"
    $Url  = "https://github.com/fishstrap/fishstrap/releases/download/v3.0.1.0/Fishstrap-v3.0.1.0.exe"

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Dang tai Fishstrap..." -ForegroundColor Cyan
    curl.exe -L $Url -o $File

    if (-not (Test-Path $File) -or (Get-Item $File).Length -eq 0) {
        Write-Host "Fishstrap tai loi hoac file rong." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Fishstrap tai thanh cong: $File" -ForegroundColor Green
    Write-Host "Dang chay installer..." -ForegroundColor Yellow

    Start-Process $File

    Write-Host "Da chay Fishstrap installer." -ForegroundColor Green
    Pause
}

# ========== 5) TAI + CAI ULTRAVIEWER ==========
function Install-UltraViewer {
    Clear-Host
    Write-Host "=== TAI + CAI ULTRAVIEWER ===" -ForegroundColor Cyan

    $Url = "https://www.ultraviewer.net/vi/UltraViewer_setup_6.6_vi.exe"
    $Out = "$env:TEMP\UltraViewer_setup.exe"

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Dang tai UltraViewer..." -ForegroundColor Cyan
    curl.exe -L $Url -o $Out

    if (-not (Test-Path $Out) -or (Get-Item $Out).Length -eq 0) {
        Write-Host "UltraViewer tai loi hoac file rong." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "UltraViewer tai thanh cong: $Out" -ForegroundColor Green
    Write-Host "Dang chay installer..." -ForegroundColor Yellow

    Start-Process $Out

    Write-Host "Da chay UltraViewer installer." -ForegroundColor Green
    Pause
}

# ========== MENU CHINH ==========
function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=========== WINDOWS UTILITY ===========" -ForegroundColor Cyan
        Write-Host "1) Fix Wave (tai bin.rar + giai nen vao AppData\\Local\\Wave)"
        Write-Host "2) Tai + chay Roblox Client"
        Write-Host "3) Tai + chay WaveBootstrapper"
        Write-Host "4) Tai + chay Fishstrap"
        Write-Host "5) Tai + cai UltraViewer"
        Write-Host "0) Thoat"
        Write-Host "======================================="
        $choice = Read-Host "Chon"

        switch ($choice) {
            '1' { Fix-Wave }
            '2' { Install-Roblox }
            '3' { Install-WaveBootstrapper }
            '4' { Install-Fishstrap }
            '5' { Install-UltraViewer }
            '0' { break }
            default {
                Write-Host "Lua chon khong hop le." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

Show-Menu
