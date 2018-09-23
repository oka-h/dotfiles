@echo off
mklink /H %userprofile%\_vimrc %~dp0\.vimrc
mklink /H %userprofile%\_gvimrc %~dp0\.gvimrc
exit /b
