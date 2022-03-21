@echo off
whoami /priv | find "SeDebugPrivilege" > nul
if errorlevel 1 (
    powershell -NoProfile -Command Start-Process \"%~f0\" -verb runas
    exit
)

powershell -NoProfile -Command New-Item -ItemType Directory -Force (Split-Path -Parent $PROFILE)
for /F "tokens=*" %%l in ('powershell -NoProfile -Command $PROFILE') do (
    mklink %%l %~dp0\Microsoft.PowerShell_profile.ps1
)
exit
