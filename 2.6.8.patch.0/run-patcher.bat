@echo off
:: Cursor Layout Menu Patcher for 2.6.8 - Double-click launcher
:: If you have issues: Right-click -> Run as administrator
powershell -ExecutionPolicy Bypass -File "%~dp0patcher.ps1" %*
echo.
pause
