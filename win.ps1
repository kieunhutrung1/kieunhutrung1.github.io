<#
    win.ps1 - Windows Utility Menu

    1) Fix Wave
    2) Tải + chạy Roblox Client
    3) Tải + chạy WaveBootstrapper
    4) Tải + chạy Fishstrap
    5) Tải + cài UltraViewer
    6) Tải + cài WinRAR (GitHub Pages)
    7) Tải + cài Chrome (GitHub Pages)
    8) Tải + cài Roblox + Wave
    9) Mở URL thư viện (Wave Library + Visual C++ AIO)
    10) Tải + cài .NET Desktop Runtime 6.0.36 + 9.0.11 (x64)
    11) Tweak Windows (UI & tiện ích)
    12) Mở thư mục %localappdata%
    13) Dọn file rác hệ thống

    0) Thoát
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

    Write-Host "[SYS] Thu muc Wave: $Dest"

    if (-not (Test-Path $Dest)) {
        Write-Host "[SYS] Thu muc Wave chua ton tai. Dang tao..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    }

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "[SYS] Dang tai bin.rar..." -ForegroundColor Cyan
    curl.exe -L $Url -o $TempFile

    if (-not (Test-Path $TempFile) -or (Get-Item $TempFile).Length -eq 0) {
        Write-Host "Tai that bai (file khong ton tai hoac rong)." -ForegroundColor Red
        Pause
        return
    }

    $WinRAR = "$env:ProgramFiles\WinRAR\winrar.exe"
    if (-not (Test-Path $WinRAR)) { $WinRAR = "$env:ProgramFiles\WinRAR\rar.exe" }

    if (-not (Test-Path $WinRAR)) {
        Write-Host "Khong tim thay WinRAR (winrar.exe / rar.exe)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "[SYS] Dang giai nen vao $Dest..." -ForegroundColor Yellow
    & $WinRAR x -y "$TempFile" "$Dest\"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Giai nen loi (exit code: $LASTEXITCODE)." -ForegroundColor Red
        Pause
        return
    }

    Write-Host "✅ Fix Wave hoan tat!" -ForegroundColor Green
    Pause
}

# ========== 2) INSTALL ROBLOX ==========
function Install-Roblox {
    Clear-Host
    Write-Host "=== TAI + CHAY ROBLOX ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $Folder = "$env:TEMP\RobloxInstall"
    if (-not (Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }

    $RobloxFile = Join-Path $Folder "RobloxPlayerInstaller.exe"

    Write-Host "[SYS] Dang tai Roblox Client..." -ForegroundColor Cyan
    curl.exe -L "https://www.roblox.com/vi/download/client?os=win" -o $RobloxFile

    if (Test-Path $RobloxFile) {
        if ((Get-Item $RobloxFile).Length -gt 0) {
            Start-Process $RobloxFile
            Write-Host "Da chay Roblox installer." -ForegroundColor Green
        } else {
            Write-Host "❌ File Roblox rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai Roblox that bai." -ForegroundColor Red
    }
    Pause
}

# ========== 3) INSTALL WAVE ==========
function Install-WaveBootstrapper {
    Clear-Host
    Write-Host "=== TAI + CHAY WAVEBootstrapper ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $Folder = "$env:TEMP\WaveInstall"
    if (-not (Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }

    $WaveFile = Join-Path $Folder "WaveBootstrapper.exe"

    Write-Host "[SYS] Dang tai WaveBootstrapper..." -ForegroundColor Cyan
    curl.exe -L "https://cdn.wavify.cc/v3/WaveBootstrapper.exe" -o $WaveFile

    if (Test-Path $WaveFile) {
        if ((Get-Item $WaveFile).Length -gt 0) {
            Start-Process $WaveFile
            Write-Host "Da chay WaveBootstrapper." -ForegroundColor Green
        } else {
            Write-Host "❌ File WaveBootstrapper rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai Wave that bai." -ForegroundColor Red
    }
    Pause
}

# ========== 4) INSTALL FISHSTRAP ==========
function Install-Fishstrap {
    Clear-Host
    Write-Host "=== TAI + CHAY FISHSTRAP ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $Folder = "$env:TEMP\FishstrapInstall"
    if (-not (Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }

    $File = Join-Path $Folder "Fishstrap.exe"
    $Url  = "https://github.com/fishstrap/fishstrap/releases/download/v3.0.1.0/Fishstrap-v3.0.1.0.exe"

    Write-Host "[SYS] Dang tai Fishstrap..." -ForegroundColor Cyan
    curl.exe -L $Url -o $File

    if (Test-Path $File) {
        if ((Get-Item $File).Length -gt 0) {
            Start-Process $File
            Write-Host "Da chay Fishstrap installer." -ForegroundColor Green
        } else {
            Write-Host "❌ File Fishstrap rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai Fishstrap that bai." -ForegroundColor Red
    }
    Pause
}

# ========== 5) INSTALL ULTRAVIEWER ==========
function Install-UltraViewer {
    Clear-Host
    Write-Host "=== TAI + CAI ULTRAVIEWER ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $Url = "https://www.ultraviewer.net/vi/UltraViewer_setup_6.6_vi.exe"
    $Out = "$env:TEMP\UltraViewer_setup.exe"

    Write-Host "[SYS] Dang tai UltraViewer..." -ForegroundColor Cyan
    curl.exe -L $Url -o $Out

    if (Test-Path $Out) {
        if ((Get-Item $Out).Length -gt 0) {
            Start-Process $Out
            Write-Host "Da chay UltraViewer installer." -ForegroundColor Green
        } else {
            Write-Host "❌ File UltraViewer rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai UltraViewer that bai." -ForegroundColor Red
    }
    Pause
}

# ========== 6) INSTALL WINRAR ==========
function Install-WinRAR {
    Clear-Host
    Write-Host "=== TAI + CAI WINRAR ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $Url = "https://kieunhutrung1.github.io/debs/winrar.exe"
    $Out = "$env:TEMP\winrar.exe"

    Write-Host "[SYS] Dang tai WinRAR..." -ForegroundColor Cyan
    curl.exe -L $Url -o $Out

    if (Test-Path $Out) {
        if ((Get-Item $Out).Length -gt 0) {
            Start-Process $Out
            Write-Host "Da chay WinRAR installer." -ForegroundColor Green
        } else {
            Write-Host "❌ File WinRAR rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai WinRAR that bai." -ForegroundColor Red
    }
    Pause
}

# ========== 7) INSTALL CHROME ==========
function Install-ChromeFromGH {
    Clear-Host
    Write-Host "=== TAI + CAI CHROME ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $Url = "https://kieunhutrung1.github.io/debs/ChromeSetup.exe"
    $Out = "$env:TEMP\ChromeSetup.exe"

    Write-Host "[SYS] Dang tai ChromeSetup.exe..." -ForegroundColor Cyan
    curl.exe -L $Url -o $Out

    if (Test-Path $Out) {
        if ((Get-Item $Out).Length -gt 0) {
            Start-Process $Out
            Write-Host "Da chay Chrome installer." -ForegroundColor Green
        } else {
            Write-Host "❌ File Chrome rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai Chrome that bai." -ForegroundColor Red
    }
    Pause
}

# ========== 8) INSTALL ROBLOX + WAVE ==========
function Install-RobloxWave {
    Clear-Host
    Write-Host "=== CAI ROBLOX + WAVE ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    # Roblox
    $Roblox = "$env:TEMP\Roblox_All.exe"
    Write-Host "[SYS] Dang tai Roblox..." -ForegroundColor Cyan
    curl.exe -L "https://www.roblox.com/vi/download/client?os=win" -o $Roblox
    if (Test-Path $Roblox) {
        if ((Get-Item $Roblox).Length -gt 0) {
            Start-Process $Roblox
            Write-Host "Da chay Roblox installer." -ForegroundColor Green
        } else {
            Write-Host "❌ File Roblox rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai Roblox that bai." -ForegroundColor Red
    }

    # Wave
    $Wave = "$env:TEMP\WaveBootstrapper.exe"
    Write-Host "[SYS] Dang tai WaveBootstrapper..." -ForegroundColor Cyan
    curl.exe -L "https://cdn.wavify.cc/v3/WaveBootstrapper.exe" -o $Wave
    if (Test-Path $Wave) {
        if ((Get-Item $Wave).Length -gt 0) {
            Start-Process $Wave
            Write-Host "Da chay WaveBootstrapper." -ForegroundColor Green
        } else {
            Write-Host "❌ File WaveBootstrapper rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai Wave that bai." -ForegroundColor Red
    }

    Write-Host "Hoan tat cai Roblox + Wave!" -ForegroundColor Green
    Pause
}

# ========== 9) OPEN LIBRARY URLs ==========
function Open-LibraryURLs {
    Clear-Host
    Write-Host "=== MO URL THU VIEN ===" -ForegroundColor Cyan

    Start-Process "https://rdd.whatexpsare.online/?channel=LIVE&binaryType=WindowsPlayer&version=version-e380c8edc8f6477c"
    Start-Process "https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/"

    Write-Host "Da mo 2 URL thu vien!" -ForegroundColor Green
    Pause
}

# ========== 10) INSTALL .NET DESKTOP 6.0.36 + 9.0.11 ==========
function Install-NetDesktop-6-9 {
    Clear-Host
    Write-Host "=== CAI .NET DESKTOP RUNTIME 6.0.36 + 9.0.11 (x64) ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    # .NET 6.0.36
    $Url6 = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe"
    $Out6 = "$env:TEMP\windowsdesktop-runtime-6.0.36-win-x64.exe"

    Write-Host "`nDang tai .NET Desktop Runtime 6.0.36..." -ForegroundColor Yellow
    curl.exe -L $Url6 -o $Out6

    if (Test-Path $Out6) {
        if ((Get-Item $Out6).Length -gt 0) {
            Write-Host "Cai .NET 6.0.36..." -ForegroundColor Cyan
            Start-Process $Out6 -ArgumentList "/passive","/norestart" -Wait
            Write-Host "✅ Da cai xong .NET Desktop Runtime 6.0.36." -ForegroundColor Green
        } else {
            Write-Host "❌ File .NET 6.0.36 rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai .NET 6.0.36 that bai hoac file rong." -ForegroundColor Red
    }

    # .NET 9.0.11
    $Url9 = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.11/windowsdesktop-runtime-9.0.11-win-x64.exe"
    $Out9 = "$env:TEMP\windowsdesktop-runtime-9.0.11-win-x64.exe"

    Write-Host "`nDang tai .NET Desktop Runtime 9.0.11..." -ForegroundColor Yellow
    curl.exe -L $Url9 -o $Out9

    if (Test-Path $Out9) {
        if ((Get-Item $Out9).Length -gt 0) {
            Write-Host "Cai .NET 9.0.11..." -ForegroundColor Cyan
            Start-Process $Out9 -ArgumentList "/passive","/norestart" -Wait
            Write-Host "✅ Da cai xong .NET Desktop Runtime 9.0.11." -ForegroundColor Green
        } else {
            Write-Host "❌ File .NET 9.0.11 rong." -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Tai .NET 9.0.11 that bai hoac file rong." -ForegroundColor Red
    }

    Write-Host "`nHoan tat xu ly .NET 6 + 9." -ForegroundColor Magenta
    Pause
}

# ========== 11) TWEAK WINDOWS (UI & TIEN ICH) ==========
function Tweak-Windows-UI {
    Clear-Host
    Write-Host "=== TWEAK WINDOWS (UI & TIEN ICH) ===" -ForegroundColor Cyan

    Write-Host "[SYS] Tat sleep + tat tat man hinh + hibernate..." -ForegroundColor Yellow
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -monitor-timeout-dc 0
    powercfg -h off

    Write-Host "[SYS] Hien This PC + Recycle Bin..." -ForegroundColor Yellow
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f | Out-Null

    Write-Host "[SYS] Tat People bar..." -ForegroundColor Yellow
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v PeopleBand /t REG_DWORD /d 0 /f | Out-Null

    Write-Host "[SYS] Dat Windows Search = icon..." -ForegroundColor Yellow
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f | Out-Null

    Write-Host "[SYS] Hien Task View + Touch Keyboard..." -ForegroundColor Yellow
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTouchKeyboardButton /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\Software\Microsoft\TabletTip\1.7" /v TipbandEnabled /t REG_DWORD /d 1 /f | Out-Null
    sc config TabletInputService start= auto >$null 2>&1
    sc start TabletInputService >$null 2>&1

    Write-Host "[SYS] Tat News & Interests..." -ForegroundColor Yellow
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f | Out-Null

    Write-Host "[SYS] Restart explorer..." -ForegroundColor Yellow
    taskkill /f /im explorer.exe >$null 2>&1
    Start-Process explorer.exe

    Write-Host "`n✅ Tweak Windows (UI) hoan tat." -ForegroundColor Green
    Pause
}

# ========== 12) OPEN LOCALAPPDATA ==========
function Open-LocalAppData {
    Clear-Host
    Write-Host "=== MO THU MUC %LOCALAPPDATA% ===" -ForegroundColor Cyan

    Start-Process $env:LOCALAPPDATA

    Write-Host "Da mo thu muc: $env:LOCALAPPDATA" -ForegroundColor Green
    Pause
}

# ========== 13) DON FILE RAC HE THONG ==========
function Clean-SystemJunk {
    Clear-Host
    Write-Host "=== DON FILE RAC HE THONG ===" -ForegroundColor Cyan

    $paths = @()

    if ($env:TEMP) {
        $paths += $env:TEMP
    }
    if ($env:LOCALAPPDATA) {
        $paths += (Join-Path $env:LOCALAPPDATA "Temp")
    }
    if ($env:WINDIR) {
        $paths += (Join-Path $env:WINDIR "Temp")
    }

    foreach ($p in $paths) {
        if (-not (Test-Path $p)) { continue }

        Write-Host "Don thu muc: $p" -ForegroundColor Yellow
        try {
            Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            # Bo qua neu co file khong xoa duoc
        }
    }

    Write-Host "Don Recycle Bin..." -ForegroundColor Yellow
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    } catch {
        # Neu loi (PowerShell cu), bo qua
    }

    Write-Host "`n✅ Da don file rac co ban (Temp + Recycle Bin)." -ForegroundColor Green
    Pause
}

# ========== MENU ==========
function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=========== WINDOWS UTILITY ===========" -ForegroundColor Cyan
        Write-Host "1) Fix Wave"
        Write-Host "2) Tai + chay Roblox"
        Write-Host "3) Tai + chay WaveBootstrapper"
        Write-Host "4) Tai + chay Fishstrap"
        Write-Host "5) Tai + cai UltraViewer"
        Write-Host "6) Tai + cai WinRAR"
        Write-Host "7) Tai + cai Chrome"
        Write-Host "8) Tai + cai Roblox + Wave"
        Write-Host "9) Mo URL thu vien (Wave + Visual C++ AIO)"
        Write-Host "10) Tai + cai .NET Desktop Runtime 6.0.36 + 9.0.11"
        Write-Host "11) Tweak Windows (UI & tien ich)"
        Write-Host "12) Mo thu muc %localappdata%"
        Write-Host "13) Don file rac he thong"
        Write-Host "0) Thoat"
        Write-Host "======================================="
        $choice = Read-Host "Chon"

        switch ($choice) {
            '1'  { Fix-Wave }
            '2'  { Install-Roblox }
            '3'  { Install-WaveBootstrapper }
            '4'  { Install-Fishstrap }
            '5'  { Install-UltraViewer }
            '6'  { Install-WinRAR }
            '7'  { Install-ChromeFromGH }
            '8'  { Install-RobloxWave }
            '9'  { Open-LibraryURLs }
            '10' { Install-NetDesktop-6-9 }
            '11' { Tweak-Windows-UI }
            '12' { Open-LocalAppData }
            '13' { Clean-SystemJunk }
            '0'  { return }
            default {
                Write-Host "Lua chon khong hop le." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

Show-Menu
