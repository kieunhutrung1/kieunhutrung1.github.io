<#
    Simple Windows Utility by YOU
    - Tweak Windows
    - Debloat (remove some bloat apps)
    - Install common apps via winget
#>

# ================== CHECK ADMIN ==================
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Warning "Hãy chạy PowerShell bằng Run as administrator rồi thử lại."
    Read-Host "Nhấn Enter để thoát"
    exit
}

# ================== HELPER ==================
function Pause {
    Write-Host
    Read-Host "Nhấn Enter để quay lại menu..."
}

function Write-Title($text) {
    Clear-Host
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Yellow
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host
}

# ================== TWEAK WINDOWS ==================
function Disable-Telemetry {
    Write-Host "[*] Tắt một số telemetry & diag tracking..." -ForegroundColor Cyan

    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force

    $services = @(
        "DiagTrack",          # Connected User Experiences and Telemetry
        "dmwappushservice"    # WAP Push
    )

    foreach ($svc in $services) {
        Write-Host "  - Tắt service $svc"
        Get-Service -Name $svc -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Stop-Service $_.Name -Force -ErrorAction SilentlyContinue
                Set-Service $_.Name -StartupType Disabled
            } catch {}
        }
    }

    # Một số scheduled task
    $tasks = @(
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    )

    foreach ($task in $tasks) {
        schtasks.exe /Change /TN $task /DISABLE 2>$null
    }

    Write-Host "Hoàn tất Disable-Telemetry (cần restart để áp dụng hết)." -ForegroundColor Green
}

function Set-PerformancePowerPlan {
    Write-Host "[*] Đặt power plan Performance..." -ForegroundColor Cyan
    # High performance (nếu có)
    $plan = powercfg -list | Select-String "High performance"
    if ($plan) {
        $guid = ($plan -split '\s+')[3]
        powercfg -setactive $guid
        Write-Host "Đã chọn High performance." -ForegroundColor Green
    } else {
        Write-Host "Không tìm thấy High performance, dùng balanced mặc định." -ForegroundColor Yellow
    }
}

function Tweak-WindowsMenu {
    while ($true) {
        Write-Title "TWEAK WINDOWS"
        Write-Host "1) Tắt bớt Telemetry / Tracking"
        Write-Host "2) Đặt Power Plan High Performance"
        Write-Host "3) Chạy cả 1 + 2"
        Write-Host "0) Quay lại"
        Write-Host
        $c = Read-Host "Chọn"

        switch ($c) {
            '1' { Disable-Telemetry; Pause }
            '2' { Set-PerformancePowerPlan; Pause }
            '3' {
                Disable-Telemetry
                Set-PerformancePowerPlan
                Pause
            }
            '0' { break }
            default { Write-Host "Lựa chọn không hợp lệ." -ForegroundColor Red; Start-Sleep 1 }
        }
    }
}

# ================== DEBLOAT APPS ==================
function Debloat-Apps {
    Write-Title "DEBLOAT - GỠ MỘT SỐ APP UWP THƯA THẢI"
    Write-Host "Lưu ý: chỉ gỡ một số app như Xbox, 3D Viewer, People, Skype, GetHelp,..."
    Write-Host "Không đụng tới Store, Settings, Photos, Calculator..." -ForegroundColor Yellow
    Write-Host
    $ok = Read-Host "Nhập Y để tiếp tục, phím khác để hủy"

    if ($ok -ne 'Y' -and $ok -ne 'y') {
        Write-Host "Đã hủy." -ForegroundColor Yellow
        Pause
        return
    }

    $apps = @(
        "Microsoft.XboxGamingOverlay",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MixedReality.Portal",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted"
    )

    foreach ($app in $apps) {
        Write-Host "Gỡ $app cho tất cả user..."
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Host
    Write-Host "Đã chạy debloat, có thể cần restart." -ForegroundColor Green
    Pause
}

# ================== INSTALL APPS ==================
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        return $true
    } else {
        Write-Host "Không tìm thấy winget. Cập nhật Microsoft Store / App Installer trước." -ForegroundColor Red
        Pause
        return $false
    }
}

function Install-AppList {
    if (-not (Ensure-Winget)) { return }

    Write-Title "CÀI APP BẰNG WINGET"
    Write-Host "Apps sẽ cài (có thể chỉnh trong script):" -ForegroundColor Yellow
    Write-Host " - Google Chrome"
    Write-Host " - 7-Zip"
    Write-Host " - Visual Studio Code"
    Write-Host
    $ok = Read-Host "Nhập Y để cài, phím khác để hủy"

    if ($ok -ne 'Y' -and $ok -ne 'y') {
        Write-Host "Đã hủy cài đặt ứng dụng." -ForegroundColor Yellow
        Pause
        return
    }

    $apps = @(
        @{ id = "Google.Chrome";        name = "Google Chrome" },
        @{ id = "7zip.7zip";            name = "7-Zip" },
        @{ id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code" }
    )

    foreach ($a in $apps) {
        Write-Host "Cài $($a.name)..."
        winget install -e --id $a.id --silent --accept-package-agreements --accept-source-agreements
    }

    Write-Host
    Write-Host "Hoàn tất install apps (kiểm tra lại trong Start Menu)." -ForegroundColor Green
    Pause
}

# ================== MAIN MENU ==================
function Show-MainMenu {
    while ($true) {
        Write-Title "WINDOWS UTILITY - MENU CHÍNH"
        Write-Host "1) Tweak Windows (telemetry, power plan...)"
        Write-Host "2) Debloat - gỡ một số app rác UWP"
        Write-Host "3) Install Apps (Chrome, 7zip, VS Code...)"
        Write-Host "0) Thoát"
        Write-Host
        $choice = Read-Host "Chọn"

        switch ($choice) {
            '1' { Tweak-WindowsMenu }
            '2' { Debloat-Apps }
            '3' { Install-AppList }
            '0' { break }
            default {
                Write-Host "Lựa chọn không hợp lệ." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

# ====== START ======
Show-MainMenu
