@echo off
setlocal

set LOG_RUTA=%~dp0..\..\frontend-3100.log

set PORT=3100
set NEXT_PUBLIC_API_URL=http://127.0.0.1:3101/api/v1
set API_BASE_INTERNA=http://127.0.0.1:3101/api/v1
set NEXT_PUBLIC_WEBSOCKET_URL=http://127.0.0.1:3101
set NEXT_PUBLIC_VERSION_APP=1.0.0

cd /d "%~dp0.."
call npm run start >> "%LOG_RUTA%" 2>&1
