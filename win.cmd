@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ===================== CONFIG =====================
set "URL=https://pub-f1b80f1b35454cc7b6a3e1c7baaea03f.r2.dev/roblox/update.rar"
set "DEST=%USERPROFILE%\Desktop\RobloxS"
set "TMP=%TEMP%\RobloxS_Update"
set "RAR=%TMP%\update.rar"

:: ===================== MENU =====================
:MENU
cls
echo ==========================================
echo          RobloxS Updater (CMD)
echo ==========================================
echo  [1] Update RobloxS (tai + xoa + giai nen)
echo  [0] Thoat
echo.
set /p "CHOICE=Chon: "
if "%CHOICE%"=="1" goto DO_UPDATE
if "%CHOICE%"=="0" goto END
goto MENU

:: ===================== UPDATE =====================
:DO_UPDATE
cls
echo [*] Tao thu muc tam...
if not exist "%TMP%" mkdir "%TMP%" >nul 2>&1

echo [*] Kiem tra curl...
where curl >nul 2>&1
if errorlevel 1 (
  echo [X] Khong tim thay curl.
  echo     Goi y: Windows 10/11 thuong co san curl, hay cap nhat Windows hoac cai curl.
  pause
  goto MENU
)

echo [*] Tai file: %URL%
del /f /q "%RAR%" >nul 2>&1

curl -L --fail --silent --show-error "%URL%" -o "%RAR%"
if errorlevel 1 (
  echo [X] Loi tai file!
  pause
  goto MENU
)

echo [*] Xoa thu muc dich truoc khi giai nen: "%DEST%"
if exist "%DEST%" (
  rmdir /s /q "%DEST%" >nul 2>&1
)

echo [*] Tao lai thu muc dich...
mkdir "%DEST%" >nul 2>&1

echo [*] Tim WinRAR...
set "WINRAR="
if exist "%ProgramFiles%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles%\WinRAR\WinRAR.exe"
if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"

if defined WINRAR goto EXTRACT_WINRAR

echo [!] Khong tim thay WinRAR, thu dung 7-Zip...
set "SEVENZIP="
if exist "%ProgramFiles%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles%\7-Zip\7z.exe"
if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"

if defined SEVENZIP goto EXTRACT_7Z

echo [X] Khong tim thay WinRAR hoac 7-Zip.
echo     Cai WinRAR (WinRAR.exe) hoac 7-Zip (7z.exe) roi chay lai.
pause
goto MENU

:EXTRACT_WINRAR
echo [*] Giai nen bang WinRAR...
"%WINRAR%" x -o+ -ibck "%RAR%" "%DEST%\"
if errorlevel 1 (
  echo [X] Loi giai nen (WinRAR)!
  pause
  goto MENU
)
goto DONE

:EXTRACT_7Z
echo [*] Giai nen bang 7-Zip...
"%SEVENZIP%" x -y "%RAR%" -o"%DEST%"
if errorlevel 1 (
  echo [X] Loi giai nen (7-Zip)!
  pause
  goto MENU
)
goto DONE

:DONE
echo.
echo [OK] Update xong!
echo     Thu muc: "%DEST%"
pause
goto MENU

:END
endlocal
exit /b
