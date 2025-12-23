@echo off
chcp 65001 >nul
title Roblox Updater
cls

:: ====== CONFIG ======
set URL=https://pub-f1b80f1b35454cc7b6a3e1c7baaea03f.r2.dev/roblox/update.rar
set DESKTOP=%USERPROFILE%\Desktop
set DEST=%DESKTOP%\RobloxS
set RARFILE=%DESKTOP%\update.rar
set WINRAR="C:\Program Files\WinRAR\WinRAR.exe"
:: ====================

:menu
cls
echo ==================================
echo        ROBLOX UPDATE MENU
echo ==================================
echo.
echo [1] Update Roblox (Download + Extract)
echo [2] Open RobloxS folder
echo [0] Exit
echo.
set /p choice=Chon:

if "%choice%"=="1" goto update
if "%choice%"=="2" goto open
if "%choice%"=="0" exit
goto menu

:update
cls
echo [*] Dang tai update.rar ...
curl -L "%URL%" -o "%RARFILE%"
if errorlevel 1 (
    echo [X] Loi tai file!
    pause
    goto menu
)

echo [*] Tao thu muc RobloxS ...
if not exist "%DEST%" mkdir "%DEST%"

echo [*] Dang giai nen bang WinRAR ...
%WINRAR% x -y "%RARFILE%" "%DEST%\"
if errorlevel 1 (
    echo [X] Loi giai nen!
    pause
    goto menu
)

echo.
echo [✓] UPDATE THANH CONG!
echo Thu muc: %DEST%
pause
goto menu

:open
explorer "%DEST%"
goto menu
