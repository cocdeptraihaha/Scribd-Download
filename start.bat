@echo off
REM Script tự động tải và sử dụng portable Node.js
REM Không cần cài Node.js!

setlocal enabledelayedexpansion

echo ========================================
echo   Scribd Downloader - Portable Mode
echo   Khong can cai Node.js!
echo ========================================
echo.

set "NODE_DIR=node-portable"
set "NODE_VERSION=v20.11.0"

REM Kiểm tra xem đã có portable Node.js chưa
if exist "%NODE_DIR%\node.exe" (
    echo [OK] Da co portable Node.js
    goto :run
)

echo [INFO] Dang tai portable Node.js...
echo [INFO] Co the mat vai phut lan dau tien...
echo.

REM Tạo thư mục
if not exist "%NODE_DIR%" mkdir "%NODE_DIR%"

REM Tải Node.js portable cho Windows
set "NODE_URL=https://nodejs.org/dist/%NODE_VERSION%/node-%NODE_VERSION%-win-x64.zip"
set "ZIP_FILE=%NODE_DIR%\node.zip"

echo [INFO] Dang tai tu: %NODE_URL%
echo.

REM Sử dụng PowerShell để tải file
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%ZIP_FILE%'}"

if not exist "%ZIP_FILE%" (
    echo [ERROR] Khong the tai Node.js!
    echo Vui long kiem tra ket noi internet.
    pause
    exit /b 1
)

echo [INFO] Dang giai nen...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%NODE_DIR%\temp' -Force"

REM Di chuyển file node.exe
if exist "%NODE_DIR%\temp\node-%NODE_VERSION%-win-x64\node.exe" (
    copy "%NODE_DIR%\temp\node-%NODE_VERSION%-win-x64\node.exe" "%NODE_DIR%\node.exe" >nul
    copy "%NODE_DIR%\temp\node-%NODE_VERSION%-win-x64\npm.cmd" "%NODE_DIR%\npm.cmd" >nul 2>nul
    copy "%NODE_DIR%\temp\node-%NODE_VERSION%-win-x64\npm" "%NODE_DIR%\pm" >nul 2>nul
    
    REM Copy thư mục node_modules từ portable
    if exist "%NODE_DIR%\temp\node-%NODE_VERSION%-win-x64\node_modules" (
        xcopy /E /I /Y "%NODE_DIR%\temp\node-%NODE_VERSION%-win-x64\node_modules" "%NODE_DIR%\node_modules" >nul
    )
    
    REM Xóa file tạm
    rmdir /S /Q "%NODE_DIR%\temp" 2>nul
    del "%ZIP_FILE%" 2>nul
)

if not exist "%NODE_DIR%\node.exe" (
    echo [ERROR] Khong the giai nen Node.js!
    pause
    exit /b 1
)

echo [OK] Da tai xong portable Node.js!
echo.

:run
REM Set PATH để sử dụng portable Node.js
set "PATH=%CD%\%NODE_DIR%;%PATH%"

REM Kiểm tra Node.js
"%NODE_DIR%\node.exe" --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Portable Node.js khong hoat dong!
    pause
    exit /b 1
)

echo [OK] Portable Node.js: 
"%NODE_DIR%\node.exe" --version
echo.

REM Chuyển vào thư mục scribd-dl
cd scribd-dl

REM Kiểm tra node_modules của project
if not exist "node_modules\" (
    echo [INFO] Dang cai dat dependencies...
    "..\%NODE_DIR%\node.exe" "..\%NODE_DIR%\node_modules\npm\bin\npm-cli.js" install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Khong the cai dat dependencies!
        pause
        exit /b 1
    )
    echo [OK] Da cai dat xong dependencies
    echo.
) else (
    echo [OK] Dependencies da duoc cai dat
    echo.
)

REM Kiểm tra thư mục output
if not exist "output\" mkdir output

REM Kiểm tra config.ini
if not exist "config.ini" (
    (
        echo [SCRIBD]
        echo rendertime=100
        echo.
        echo [DIRECTORY]
        echo output=output
        echo filename=title
    ) > config.ini
)

echo ========================================
echo   Dang khoi dong server...
echo ========================================
echo.
echo Server se chay tai: http://localhost:3000
echo Dang mo trinh duyet...
echo Nhan Ctrl+C de dung server
echo.

REM Chạy server với portable Node.js trong background
start "" "..\%NODE_DIR%\node.exe" server.js

REM Chờ server khởi động (3 giây)
timeout /t 3 /nobreak >nul

REM Mở trình duyệt
start http://localhost:3000

echo.
echo Server dang chay trong cua so khac.
echo Trinh duyet da duoc mo tai http://localhost:3000
echo.
echo De dong server, dong cua so server hoac nhan Ctrl+C trong cua so do.
echo.
pause

