@echo off
whoami /priv | find "SeDebugPrivilege" > nul
if errorlevel 1 (
    powershell -Command Start-Process \"%~f0\" -verb runas
    exit
)

mklink %userprofile%\_vimrc %~dp0\.vimrc
mklink %userprofile%\_gvimrc %~dp0\.gvimrc
exit
