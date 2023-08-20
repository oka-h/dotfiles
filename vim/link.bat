@echo off

whoami /priv | find "SeDebugPrivilege" > nul

if errorlevel 1 (
    powershell -NoProfile -Command Start-Process \"%~f0\" -verb runas
    exit
)

mklink "%userprofile%\_vimrc" "%~dp0\.vimrc"
mklink "%userprofile%\_gvimrc" "%~dp0\.gvimrc"

if not exist "%userprofile%\AppData\Local\nvim" (
    mkdir "%userprofile%\AppData\Local\nvim"
)

mklink "%userprofile%\AppData\Local\nvim\init.vim" "%~dp0\.vimrc"
mklink "%userprofile%\AppData\Local\nvim\ginit.vim" "%~dp0\.gvimrc"

exit
