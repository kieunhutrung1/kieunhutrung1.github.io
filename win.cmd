@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title RobloxS Updater (CMD)

REM ===== CONFIG =====
set "URL=https://pub-f1b80f1b35454cc7b6a3e1c7baaea03f.r2.dev/roblox/update.rar"
set "DEST=%USERPROFILE%\Desktop\RobloxS"
set "RAR=%TEMP%\RobloxS_update.rar"
set "MARK=%DEST%\.update_ok"

REM ===== MENU =====
:MENU
cls
echo ================================
echo        RobloxS Updater
echo ================================
echo.
echo [1] Update RobloxS (tai + giai nen)
echo [2] Thoat
echo.
set /p "CHOICE=Nhap lua chon: "
if "%CHOICE%"=="1" goto DO_UPDATE
if "%CHOICE%"=="2" goto END
echo.
echo [!] Lua chon khong hop le.
pause >nul
goto MENU

REM ===== UPDATE =====
:DO_UPDATE
cls
echo [*] Kiem tra curl...
where curl >nul 2>&1 || (
  echo [X] Khong tim thay curl.
  echo     Goi y: Windows 10/11 thuong co san curl, hoac cai them (winget/choco).
  pause
  goto MENU
)

echo [*] Kiem tra WinRAR...
call :FIND_WINRAR
if not defined WINRAR (
  echo [X] Khong tim thay WinRAR (WinRAR.exe).
  echo     Cai WinRAR roi thu lai.
  pause
  goto MENU
)
echo [+] WinRAR: "%WINRAR%"
echo.

echo [*] Tao thu muc dich: "%DEST%"
if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1

echo [*] Xoa noi dung cu trong thu muc dich...
REM xoa tat ca file/thu muc con, giu lai thu muc DEST
for /f "delims=" %%D in ('dir /b /a "%DEST%" 2^>nul') do (
  rmdir /s /q "%DEST%\%%D" >nul 2>&1
  del /f /q "%DEST%\%%D" >nul 2>&1
)

echo [*] Tai file: %URL%
del /f /q "%RAR%" >nul 2>&1
curl -fL --retry 3 --retry-delay 2 -o "%RAR%" "%URL%"
if errorlevel 1 (
  echo [X] Loi tai file!
  pause
  goto MENU
)

for %%A in ("%RAR%") do if %%~zA LSS 10240 (
  echo [X] File tai ve qua nho (co the bi loi/chan).
  echo     Kiem tra lai link.
  pause
  goto MENU
)

echo [*] Giai nen ra: "%DEST%"
REM x = extract with full paths, -o+ overwrite all, -y yes, -ibck background (optional)
"%WINRAR%" x -o+ -y "%RAR%" "%DEST%\"
if errorlevel 1 (
  echo [X] Loi giai nen!
  pause
  goto MENU
)

echo OK > "%MARK%" 2>nul
echo.
echo [+] Update xong! Thu muc: "%DEST%"
pause
goto MENU

REM ===== FIND WINRAR =====
:FIND_WINRAR
set "WINRAR="
if exist "%ProgramFiles%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles%\WinRAR\WinRAR.exe"
if not defined WINRAR if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"
if not defined WINRAR (
  for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe" /ve 2^>nul ^| find /i "REG_SZ"') do (
    set "WINRAR=%%B"
  )
)
exit /b

:END
endlocal
exit /b
