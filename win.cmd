@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM ====== CONFIG ======
set "URL=https://pub-f1b80f1b35454cc7b6a3e1c7baaea03f.r2.dev/roblox/update.rar"
set "DEST=%USERPROFILE%\Desktop\RobloxS"
set "RARFILE=%TEMP%\update.rar"
set "LOG=%TEMP%\robloxs_update.log"

REM ====== FIND WINRAR ======
set "WINRAR="
if exist "%ProgramFiles%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles%\WinRAR\WinRAR.exe"
if not defined WINRAR if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" set "WINRAR=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"

cls
echo ===============================
echo        RobloxS Updater
echo ===============================
echo.
echo [1] Update RobloxS (tai + giai nen)
echo [2] Chi tai file update.rar
echo [3] Chi giai nen (neu da co file)
echo [0] Thoat
echo.
set /p "CHON=Nhap lua chon: "

if "%CHON%"=="1" goto DO_ALL
if "%CHON%"=="2" goto DO_DL
if "%CHON%"=="3" goto DO_EXTRACT
if "%CHON%"=="0" goto END
goto BAD

:DO_ALL
call :DOWNLOAD || goto FAIL
call :EXTRACT || goto FAIL
echo.
echo [OK] Da update xong: "%DEST%"
pause
goto END

:DO_DL
call :DOWNLOAD || goto FAIL
echo.
echo [OK] Da tai xong: "%RARFILE%"
pause
goto END

:DO_EXTRACT
call :EXTRACT || goto FAIL
echo.
echo [OK] Da giai nen xong: "%DEST%"
pause
goto END

:DOWNLOAD
echo.
echo ==== Dang tai file...
if exist "%RARFILE%" del /f /q "%RARFILE%" >nul 2>&1

where curl >nul 2>&1
if errorlevel 1 (
  echo [X] May khong co curl (Windows qua cu).
  exit /b 1
)

REM -L follow redirect, --retry retry, -o output
curl -L --retry 3 --retry-delay 2 -o "%RARFILE%" "%URL%" >"%LOG%" 2>&1
if errorlevel 1 (
  echo [X] Loi tai file! Xem log: "%LOG%"
  exit /b 1
)

if not exist "%RARFILE%" (
  echo [X] Tai xong nhung khong thay file: "%RARFILE%"
  exit /b 1
)

for %%A in ("%RARFILE%") do if %%~zA LSS 10240 (
  echo [X] File tai ve qua nho (%%~zA bytes) - co the link loi.
  exit /b 1
)

echo [OK] Tai thanh cong.
exit /b 0

:EXTRACT
echo.
echo ==== Dang giai nen...
if not defined WINRAR (
  echo [X] Khong tim thay WinRAR. Cai WinRAR truoc nhe.
  exit /b 1
)

if not exist "%RARFILE%" (
  echo [X] Chua co file "%RARFILE%". Hay chon (2) de tai truoc.
  exit /b 1
)

if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1

REM x = extract with full paths
REM -o+ overwrite all
REM -ibck run in background mode (no prompts)
"%WINRAR%" x -o+ -ibck "%RARFILE%" "%DEST%\" >>"%LOG%" 2>&1
if errorlevel 1 (
  echo [X] Loi giai nen! Xem log: "%LOG%"
  exit /b 1
)

echo [OK] Giai nen thanh cong.
exit /b 0

:BAD
echo.
echo [X] Lua chon khong hop le.
pause
goto END

:FAIL
echo.
echo [X] That bai. Mo log neu can: "%LOG%"
pause
goto END

:END
endlocal
exit /b
