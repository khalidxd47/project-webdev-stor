@echo off
setlocal
cd /d "%~dp0"
set "STOR_PHP="
if exist "%~dp0runtime\php.exe" set "STOR_PHP=%~dp0runtime\php.exe"
if not defined STOR_PHP for /f "delims=" %%P in ('where php 2^>nul') do if not defined STOR_PHP set "STOR_PHP=%%P"
if not defined STOR_PHP if exist "C:\xampp\php\php.exe" set "STOR_PHP=C:\xampp\php\php.exe"
if not defined STOR_PHP if exist "%~dp0..\..\work\php-runtime\php.exe" set "STOR_PHP=%~dp0..\..\work\php-runtime\php.exe"
if not defined STOR_PHP (
  echo PHP was not found. See START-HERE.md to install PHP 8.2 or newer.
  pause
  exit /b 1
)
if "%~1"=="--check" (
  "%STOR_PHP%" -v
  exit /b
)
if exist "config\config.local.php" (
  "%STOR_PHP%" scripts\update-designs.php
  if errorlevel 1 (
    echo Could not connect to MySQL. Start MySQL and check config/config.local.php.
    pause
    exit /b 1
  )
)
echo STOR - HTML / CSS / JavaScript / PHP / MySQL

echo Open http://127.0.0.1:8088

echo Keep this window open. Start MySQL before the first-run setup.
"%STOR_PHP%" -S 127.0.0.1:8088 -t public router.php
pause
