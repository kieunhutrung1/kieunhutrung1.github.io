@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ====== CONFIG ======
set "RAR_URL=https://pub-f1b80f1b35454cc7b6a3e1c7baaea03f.r2.dev/roblox/update.rar"
set "DEST=%USERPROFILE%\Desktop\RobloxS"
set "TMP_RAR=%TEMP%\update_robloxS.rar"

:: ====== UI ======
title Update RobloxS (CMD)
cls
echo ==============================
echo        UPDATE ROBLOXS
echo ==============================
echo.
echo  [1] Tai + Xoa thu muc cu + Giai nen vao Desktop\RobloxS
echo  [0] Thoat
echo.
set /p "CHOICE=Nhap lua chon: "

if "%CHOICE%"=="1" goto :DO_UPDATE
if "%CHOICE%"=="0" goto :EOF

echo.
echo [X] Lua chon khong hop le!
pause
goto :EOF

:DO_UPDATE
cls
echo [*] Dang update RobloxS...
echo.

:: 1) Ensure curl exists
where curl >nul 2>&1
if errorlevel 1 (
  echo [X] Khong tim thay curl! (Windows 10/11 thuong co san)
  echo     Goi y: cai Windows update hoac cai curl.
  pause
  goto :EOF
)

:: 2) Create destination folder
if not exist "%DEST%" (
  mkdir "%DEST%" >nul 2>&1
)

:: 3) Delete all contents inside DEST (but keep folder)
echo [*] Xoa noi dung cu trong: "%DEST%"
pushd "%DEST%" >nul 2>&1
if errorlevel 1 (
  echo [X] Khong truy cap duoc thu muc dich!
  pause
  goto :EOF
)

:: Delete files
del /f /q * >nul 2>&1

:: Delete subfolders
for /d %%D in (*) do (
  rmdir /s /q "%%D" >nul 2>&1
)
popd >nul

:: 4) Download rar
echo [*] Tai file: %RAR_URL%
if exist "%TMP_RAR%" del /f /q "%TMP_RAR%" >nul 2>&1

curl -L --fail --silent --show-error "%RAR_URL%" -o "%TMP_RAR%"
if errorlevel 1 (
  echo [X] Loi tai file!
  echo     Kiem tra mang / link / firewall.
  pause
  goto :EOF
)

if not exist "%TMP_RAR%" (
  echo [X] Tai xong nhung khong tim thay file rar!
  pause
  goto :EOF
)

:: 5) Find WinRAR (WinRAR.exe or UnRAR.exe)
set "WINRAR="
if exist "%ProgramFiles%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles%\WinRAR\WinRAR.exe"
if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"

:: 6) Extract
echo [*] Dang giai nen vao: "%DEST%"

if defined WINRAR (
  "%WINRAR%" x -o+ -ibck "%TMP_RAR%" "%DEST%\" >nul
  if errorlevel 1 (
    echo [X] WinRAR giai nen bi loi!
    pause
    goto :EOF
  )
) else (
  :: Fallback: try tar (Windows 10+ sometimes supports tar; but RAR may not)
  echo [!] Khong tim thay WinRAR.exe
  echo     Hay cai WinRAR (Program Files\WinRAR) hoac sua duong dan.
  pause
  goto :EOF
)

:: 7) Done
echo.
echo [✓] Update thanh cong!
echo     Thu muc: "%DEST%"
echo.
pause
goto :EOF
