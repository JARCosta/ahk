@echo off
setlocal EnableExtensions

set "RESTIC=%LOCALAPPDATA%\Programs\Restic\restic.exe"
set "REPO=D:\Nextcloud-Restic"
set "SERVER=jar@192.168.1.11"

title Nextcloud Restic Backup

echo ==========================================
echo         NEXTCLOUD RESTIC BACKUP
echo ==========================================
echo.

REM Connect the two surviving shares cleanly
echo Connecting to server shares...
net use N: /delete >nul 2>&1
net use P: /delete >nul 2>&1

net use N: \\100.64.121.65\nextcloud-app /persistent:yes >nul 2>&1
net use P: \\100.64.121.65\nextcloud-exports /persistent:yes >nul 2>&1

timeout /t 3 /nobreak >nul

REM Check required programs and repository
if not exist "%RESTIC%" (
    echo ERROR: Restic executable not found.
    pause
    exit /b 1
)

if not exist "%REPO%\" (
    echo ERROR: Restic repository not found.
    pause
    exit /b 1
)

where ssh >nul 2>&1
if errorlevel 1 (
    echo ERROR: OpenSSH client not found.
    pause
    exit /b 1
)

REM Check server shares are available
if not exist "N:\." (
    echo ERROR: N: Server share unavailable.
    pause
    exit /b 1
)

if not exist "P:\." (
    echo ERROR: P: Server share unavailable.
    pause
    exit /b 1
)

echo Server shares are available.
echo.

REM Check SSH connectivity
echo Checking SSH connection...
ssh -o BatchMode=yes "%SERVER%" "true"

if errorlevel 1 (
    echo ERROR: Cannot connect to the Ubuntu server using SSH.
    pause
    exit /b 1
)

echo SSH connection OK.
echo.

choice /C YN /N /M "Ready to start the backup? (Y/N): "
if errorlevel 2 exit /b 0

REM Prepare Nextcloud (triggers database export)
echo.
echo ==========================================
echo         PREPARING NEXTCLOUD SERVER
echo ==========================================
echo.

ssh -t "%SERVER%" "sudo /usr/local/sbin/nextcloud-restic-prepare"
set "PREP_RC=%ERRORLEVEL%"

if not "%PREP_RC%"=="0" (
    echo.
    echo ERROR: Server preparation failed.
    ssh -t "%SERVER%" "sudo /usr/local/sbin/nextcloud-restic-finish"
    pause
    exit /b 1
)

REM Run Restic backup using the 2 clean drives
echo.
echo ==========================================
echo          RUNNING RESTIC BACKUP
echo ==========================================
echo.

"%RESTIC%" -r "%REPO%" backup ^
    "D:\Nextcloud" ^
    "N:\." ^
    "P:\." ^
    --exclude="D:\Nextcloud\.sync_*" ^
    --exclude="D:\Nextcloud\.nextcloudsync.log" ^
    --exclude="D:\Nextcloud\Desktop.ini"

set "BACKUP_RC=%ERRORLEVEL%"

REM Restore Nextcloud service
echo.
echo ==========================================
echo       RESTORING NEXTCLOUD SERVICE
echo ==========================================
echo.

ssh -t "%SERVER%" "sudo /usr/local/sbin/nextcloud-restic-finish"
set "FINISH_RC=%ERRORLEVEL%"

REM Report results
echo.
echo ==========================================
echo             BACKUP RESULTS
echo ==========================================
echo.

if "%BACKUP_RC%"=="0" (
    echo RESTIC BACKUP: SUCCESS
) else (
    echo RESTIC BACKUP: FAILED
)

if "%FINISH_RC%"=="0" (
    echo NEXTCLOUD MAINTENANCE MODE: OFF
) else (
    echo WARNING: COULD NOT VERIFY MAINTENANCE MODE IS OFF.
)

echo.
pause
exit /b 0