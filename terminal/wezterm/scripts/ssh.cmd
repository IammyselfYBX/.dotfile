@echo off
setlocal

if /I "%~1"=="work" goto work

"C:\Windows\System32\OpenSSH\ssh.exe" %*
exit /b %errorlevel%

:work
start "" /b powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Tools\WezTermTunnel\start-work.ps1"
exit /b 0