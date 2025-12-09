
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
    14) Tải client_web.exe + client_ld.exe (lưu vào CLIEN\WEB & CLIEN\LD trên Desktop)
    15) WEAO Install-version-e380c8edc8f6477c
    16) Chạy MAS (Microsoft Activation Scripts)
    17) Edit Roblox Settings (FPS + Volume + ReadOnly)
    18) Edit Wave config.json (instance settings)

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

    $Url = "https://kieunhutrung1.github.io/data/Wave.rar"
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

    Start-Process "https://rdd.weao.gg/?channel=LIVE&binaryType=WindowsPlayer&version=version-e380c8edc8f6477c&includeLauncher=true"
    Start-Process "https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/"

    Write-Host "Da mo 2 URL thu vien!" -ForegroundColor Green
    Pause
}

# ========== 10) INSTALL .NET DESKTOP 6.0.36 + 9.0.11 ==========
function Install-NetDesktop-6-9 {
   Clear-Host
    Write-Host "=== CAI FULL RUNTIME (.NET + VC++) ONLINE ===" -ForegroundColor Cyan

    # ==========================
    #   DANH SÁCH VC++ x64 ONLINE
    # ==========================

    $VCBase = "https://kieunhutrung1.github.io/data/"
    $VCFiles = @(
        "vcredist2005_x64.exe",
        "vcredist2008_x64.exe",
        "vcredist2010_x64.exe",
        "vcredist2012_x64.exe",
        "vcredist2013_x64.exe",
        "vcredist2015_2017_2019_2022_x64.exe"
    )

    # ==========================
    #   DANH SÁCH .NET RUNTIME ONLINE
    # ==========================

    $DotNetUrls = @(
        "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe",
        "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.11/windowsdesktop-runtime-9.0.11-win-x64.exe"
    )

    # ==========================
    #   CAI VC++ ONLINE
    # ==========================

    Write-Host "`n=== VC++ X64 ===" -ForegroundColor Magenta

    foreach ($file in $VCFiles) {

        $Url = $VCBase + $file
        $Out = "$env:TEMP\$file"

        Write-Host "`n📥 Dang tai: $file" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $Url -OutFile $Out -ErrorAction SilentlyContinue

        if (!(Test-Path $Out) -or ((Get-Item $Out).Length -eq 0)) {
            Write-Host "❌ Tai that bai: $file" -ForegroundColor Red
            continue
        }

        Write-Host "🔧 Cai dat (NO WAIT): $file ..." -ForegroundColor Cyan

        if ($file -like "*2005*") {
            Start-Process $Out -ArgumentList "/q"
        }
        elseif ($file -like "*2008*") {
            Start-Process $Out -ArgumentList "/qb"
        }
        else {
            Start-Process $Out -ArgumentList "/passive","/norestart"
        }

        Write-Host "▶ Da goi cai dat: $file" -ForegroundColor Green
    }

    # ==========================
    #   CAI .NET DESKTOP RUNTIME ONLINE
    # ==========================

    Write-Host "`n=== .NET DESKTOP RUNTIME ===" -ForegroundColor Magenta

    foreach ($url in $DotNetUrls) {

        $File = "$env:TEMP\" + [System.IO.Path]::GetFileName($url)

        Write-Host "`n📥 Dang tai .NET: $File" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile $File -ErrorAction SilentlyContinue

        if (!(Test-Path $File) -or ((Get-Item $File).Length -eq 0)) {
            Write-Host "❌ Tai that bai .NET: $File" -ForegroundColor Red
            continue
        }

        Write-Host "🔧 Cai dat (NO WAIT): $File ..." -ForegroundColor Cyan
        Start-Process $File -ArgumentList "/passive","/norestart"

        Write-Host "▶ Da goi cai dat: $File" -ForegroundColor Green
    }

    # ==========================
    Write-Host "`n🎉 DA GOI CAI FULL RUNTIME ONLINE (installer sẽ tự chạy nền)." -ForegroundColor Magenta
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

# ========== 14) TAI FARMSYNC CLIENT_WEB + CLIENT_LD VAO CLIEN (DESKTOP) ==========
function Install-FarmSyncClient {
    Clear-Host
    Write-Host "=== TAI FARMSYNC CLIENT (WEB + LD) VAO CLIEN (DESKTOP) ===" -ForegroundColor Cyan

    if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Khong tim thay curl.exe." -ForegroundColor Red
        Pause
        return
    }

    $desktop = [Environment]::GetFolderPath('Desktop')
    $base    = Join-Path $desktop "CLIEN"

    # 2 thu muc rieng cho WEB va LD
    $webDir = Join-Path $base "WEB"
    $ldDir  = Join-Path $base "LD"

    New-Item -ItemType Directory -Force -Path $webDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ldDir  | Out-Null

    $webPath = Join-Path $webDir "client_web.exe"
    $ldPath  = Join-Path $ldDir  "client_ld.exe"

    $urlWeb = "https://cdn.farmsync.cloud/files/client_web.exe"
    $urlLD  = "https://cdn.farmsync.cloud/files/client_ld.exe"

    Write-Host "Muon tai gi?" -ForegroundColor Yellow
    Write-Host "1) Chi client_web"
    Write-Host "2) Chi client_ld"
    Write-Host "3) Ca 2 (web + ld)"
    $choice = Read-Host "Chon (1/2/3)"

    switch ($choice) {
        '1' {
            Write-Host "[SYS] Dang tai client_web.exe vao $webDir ..."
            curl.exe -L $urlWeb -o $webPath
        }
        '2' {
            Write-Host "[SYS] Dang tai client_ld.exe vao $ldDir ..."
            curl.exe -L $urlLD -o $ldPath
        }
        '3' {
            Write-Host "[SYS] Dang tai client_web.exe vao $webDir ..."
            curl.exe -L $urlWeb -o $webPath

            Write-Host "[SYS] Dang tai client_ld.exe vao $ldDir ..."
            curl.exe -L $urlLD -o $ldPath
        }
        default {
            Write-Host "Lua chon khong hop le." -ForegroundColor Red
            Pause
            return
        }
    }

    Write-Host "`nDa luu file vao:" -ForegroundColor Green
    Write-Host " - $webDir"
    Write-Host " - $ldDir"
    Pause
}

# ========== 15) WEAO INSTALL (GIAI NEN ZIP VAO VERSION CO DINH) ==========
function Install-WEAO-Fixed {
    Clear-Host
    Write-Host "=== WEAO INSTALL (GIAI NEN ZIP VAO VERSION CO DINH) ===" -ForegroundColor Cyan

    # ZIP trong Downloads cua user hien tai
    $zip  = Join-Path $env:USERPROFILE "Downloads\WEAO-LIVE-WindowsPlayer-version-e380c8edc8f6477c.zip"

    # Thu muc dich: C:\Program Files (x86)\Roblox\Versions\version-5aed1822f52c4b03
    $pf86   = [Environment]::GetFolderPath("ProgramFilesX86")
    $verDir = Join-Path $pf86 "Roblox\Versions\version-5aed1822f52c4b03"

    $rar = "$env:ProgramFiles\WinRAR\winrar.exe"
    if (!(Test-Path $rar)) { $rar = "$env:ProgramFiles\WinRAR\rar.exe" }

    if (-not (Test-Path $rar)) {
        Write-Host "Khong tim thay WinRAR (winrar.exe / rar.exe)." -ForegroundColor Red
        Pause
        return
    }

    if (-not (Test-Path $zip)) {
        Write-Host "Khong tim thay file ZIP: $zip" -ForegroundColor Red
        Pause
        return
    }

    Write-Host "Xoa thu muc cu: $verDir"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $verDir
    New-Item -ItemType Directory -Force -Path $verDir | Out-Null

    Write-Host "Dang giai nen vao: $verDir ..."
    & $rar x -y "$zip" "$verDir\"

    Write-Host "Done!" -ForegroundColor Green
    Pause
}

# ========== 16) RUN MAS (MICROSOFT ACTIVATION SCRIPTS) ==========
function Run-MAS {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$args
    )

    if (-not $args) {
        Write-Host ''
        Write-Host 'Need help? Check our homepage: ' -NoNewline
        Write-Host 'https://massgrave.dev' -ForegroundColor Green
        Write-Host ''
    }

    & {
        $psv = (Get-Host).Version.Major
        $troubleshoot = 'https://massgrave.dev/troubleshoot'

        if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
            $ExecutionContext.SessionState.LanguageMode
            Write-Host "PowerShell is not running in Full Language Mode."
            Write-Host "Help - https://gravesoft.dev/fix_powershell" -ForegroundColor White -BackgroundColor Blue
            return
        }

        try {
            [void][System.AppDomain]::CurrentDomain.GetAssemblies(); [void][System.Math]::Sqrt(144)
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Powershell failed to load .NET command."
            Write-Host "Help - https://gravesoft.dev/in-place_repair_upgrade" -ForegroundColor White -BackgroundColor Blue
            return
        }

        function Check3rdAV {
            $cmd = if ($psv -ge 3) { 'Get-CimInstance' } else { 'Get-WmiObject' }
            $avList = & $cmd -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName

            if ($avList) {
                Write-Host '3rd party Antivirus might be blocking the script - ' -ForegroundColor White -BackgroundColor Blue -NoNewline
                Write-Host " $($avList -join ', ')" -ForegroundColor DarkRed -BackgroundColor White
            }
        }

        function CheckFile {
            param ([string]$FilePath)
            if (-not (Test-Path $FilePath)) {
                Check3rdAV
                Write-Host "Failed to create MAS file in temp folder, aborting!"
                Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
                throw
            }
        }

        try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

        $URLs = @(
            'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/f69e4ff432e465a006896de107c390220102b6d3/MAS/All-In-One-Version-KL/MAS_AIO.cmd',
            'https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&versionType=Commit&version=f69e4ff432e465a006896de107c390220102b6d3',
            'https://git.activated.win/Microsoft-Activation-Scripts/plain/MAS/All-In-One-Version-KL/MAS_AIO.cmd?id=f69e4ff432e465a006896de107c390220102b6d3'
        )
        Write-Progress -Activity "Downloading..." -Status "Please wait"
        $errors = @()
        foreach ($URL in $URLs | Sort-Object { Get-Random }) {
            try {
                if ($psv -ge 3) {
                    $response = Invoke-RestMethod $URL
                }
                else {
                    $w = New-Object Net.WebClient
                    $response = $w.DownloadString($URL)
                }
                break
            }
            catch {
                $errors += $_
            }
        }
        Write-Progress -Activity "Downloading..." -Status "Done" -Completed

        if (-not $response) {
            Check3rdAV
            foreach ($err in $errors) {
                Write-Host "Error: $($err.Exception.Message)" -ForegroundColor Red
            }
            Write-Host "Failed to retrieve MAS from any of the available repositories, aborting!"
            Write-Host "Check if antivirus or firewall is blocking the connection."
            Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
            return
        }

        # Verify script integrity
        $releaseHash = 'ABB331EDDCA1036EC2C2CE81D74A4644E86347EF06DC4842D34AA9C030E11EDF'
        $stream = New-Object IO.MemoryStream
        $writer = New-Object IO.StreamWriter $stream
        $writer.Write($response)
        $writer.Flush()
        $stream.Position = 0
        $hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)) -replace '-'
        if ($hash -ne $releaseHash) {
            Write-Warning "Hash ($hash) mismatch, aborting!`nReport this issue at $troubleshoot"
            $response = $null
            return
        }

        # Check for AutoRun registry which may create issues with CMD
        $paths = "HKCU:\SOFTWARE\Microsoft\Command Processor", "HKLM:\SOFTWARE\Microsoft\Command Processor"
        foreach ($path in $paths) {
            if (Get-ItemProperty -Path $path -Name "Autorun" -ErrorAction SilentlyContinue) {
                Write-Warning "Autorun registry found, CMD may crash! `nManually copy-paste the below command to fix...`nRemove-ItemProperty -Path '$path' -Name 'Autorun'"
            }
        }

        $rand = [Guid]::NewGuid().Guid
        $isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
        $FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\MAS_$rand.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\MAS_$rand.cmd" }
        Set-Content -Path $FilePath -Value "@::: $rand `r`n$response"
        CheckFile $FilePath

        $env:ComSpec = "$env:SystemRoot\system32\cmd.exe"
        $chkcmd = & $env:ComSpec /c "echo CMD is working"
        if ($chkcmd -notcontains "CMD is working") {
            Write-Warning "cmd.exe is not working.`nReport this issue at $troubleshoot"
        }

        if ($psv -lt 3) {
            if (Test-Path "$env:SystemRoot\Sysnative") {
                Write-Warning "Command is running with x86 Powershell, run it with x64 Powershell instead..."
                return
            }
            $p = saps -FilePath $env:ComSpec -ArgumentList "/c """"$FilePath"" -el -qedit $args""" -Verb RunAs -PassThru
            $p.WaitForExit()
        }
        else {
            saps -FilePath $env:ComSpec -ArgumentList "/c """"$FilePath"" -el $args""" -Wait -Verb RunAs
        }
        CheckFile $FilePath

        $FilePaths = @("$env:SystemRoot\Temp\MAS*.cmd", "$env:USERPROFILE\AppData\Local\Temp\MAS*.cmd")
        foreach ($FilePath in $FilePaths) { Get-Item $FilePath -ErrorAction SilentlyContinue | Remove-Item }
    } @args
}

# ========== 17) EDIT ROBLOX SETTINGS (FPS + VOLUME + READ-ONLY) ==========
function Edit-RobloxSettings {
    Clear-Host
    Write-Host "=== EDIT Roblox GlobalBasicSettings_13.xml (FPS + Volume) ===" -ForegroundColor Cyan

    $file = Join-Path $env:LOCALAPPDATA "Roblox\GlobalBasicSettings_13.xml"

    if (-not (Test-Path $file)) {
        Write-Host "Khong tim thay file: $file" -ForegroundColor Red
        Pause
        return
    }

    # Lấy thuộc tính gốc của file (để biết ban đầu có read-only không)
    $item = Get-Item $file
    $origAttrs   = $item.Attributes
    $wasReadOnly = [bool]($origAttrs -band [IO.FileAttributes]::ReadOnly)

    # Tạm tắt read-only nếu đang bật
    if ($wasReadOnly) {
        $item.Attributes = $origAttrs -band (-bnot [IO.FileAttributes]::ReadOnly)
        Write-Host "Tat tam READ-ONLY de cho phep sua..." -ForegroundColor Yellow
    }

    # Backup file
    $backup = "$file.bak"
    Copy-Item $file $backup -Force
    Write-Host "Da tao backup: $backup" -ForegroundColor DarkGray

    # Đọc nội dung hiện tại
    $content    = Get-Content $file -Raw
    $newContent = $content

    # ==== THAY FPS ====
    $newContent = $newContent -replace '<int name="FramerateCap">-1</int>', '<int name="FramerateCap">15</int>'

    # ==== THAY VOLUME ====
    $newContent = $newContent -replace '<float name="MasterVolume">1</float>',       '<float name="MasterVolume">0</float>'
    $newContent = $newContent -replace '<float name="MasterVolumeStudio">1</float>', '<float name="MasterVolumeStudio">0</float>'
    $newContent = $newContent -replace '<float name="PartyVoiceVolume">1</float>',   '<float name="PartyVoiceVolume">0</float>'

    if ($content -eq $newContent) {
        Write-Host "Khong co gi de sua (noi dung giong nhau)." -ForegroundColor Yellow

        # Không sửa gì, trả lại trạng thái read-only như ban đầu nếu có
        if ($wasReadOnly) {
            (Get-Item $file).Attributes = $origAttrs
            Write-Host "Khoi phuc lai READ-ONLY nhu ban dau." -ForegroundColor DarkGray
        }

        Pause
        return
    }

    # Ghi nội dung mới
    Set-Content -Path $file -Value $newContent -Encoding UTF8

    # Sau khi CÓ SỬA thì kích hoạt READ-ONLY
    (Get-Item $file).Attributes = [IO.FileAttributes]::ReadOnly
    Write-Host "✅ Da sua FPS + Volume va 🔒 kich hoat READ-ONLY cho file." -ForegroundColor Green

    Pause
}

# ========== 18) EDIT WAVE CONFIG.JSON ==========
function memreduct {
    $url  = "https://github.com/henrypp/memreduct/releases/download/v.3.5.2/memreduct-3.5.2-setup.exe"
    $file = "$env:TEMP\memreduct_setup.exe"

    Write-Host "`n[1] Downloading Mem Reduct..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $file

    Write-Host "[2] Installing silently..." -ForegroundColor Cyan
    Start-Process $file -ArgumentList "/SP- /VERYSILENT /NORESTART"

    Write-Host "`n✔ Mem Reduct installed successfully!" -ForegroundColor Green
Pause
}




# ========== MENU ==========
function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host "=========== WINDOWS UTILITY ===========" -ForegroundColor Cyan
        Write-Host "1) Fix Wave"
        Write-Host "2) Tai Roblox"
        Write-Host "3) Tai WaveBootstrapper"
        Write-Host "4) Tai Fishstrap"
        Write-Host "5) Tai UltraViewer"
        Write-Host "6) Tai cai WinRAR"
        Write-Host "7) Tai Chrome"
        Write-Host "8) Tai Roblox + Wave"
        Write-Host "9) Mo URL thu vien (Wave + Visual C++ AIO)"
        Write-Host "10) Tai C++ cai .NET Desktop Runtime 6.0.36 + 9.0.11"
        Write-Host "11) Tweak Windows"
        Write-Host "12) Mo thu muc %localappdata%"
        Write-Host "13) Don file rac he thong"
        Write-Host "14) Tai client_web + client_ld (CLIEN tren Desktop)"
        Write-Host "15) Ha-version-e380c8edc8f6477c"
        Write-Host "16) Chay MAS (Microsoft Activation Scripts)"
        Write-Host "17) ERoblox Settings (FPS + Volume + ReadOnly)"
        Write-Host "18) Mem Reduct"
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
            '14' { Install-FarmSyncClient }
            '15' { Install-WEAO-Fixed }
            '16' { Run-MAS }
            '17' { Edit-RobloxSettings }
            '18' { memreduct }
            '0'  { return }
            default {
                Write-Host "Lua chon khong hop le." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

Show-Menu
