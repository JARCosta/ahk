
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

REM Check all four server shares

echo Checking server shares...

if not exist "N:\." (
    echo ERROR: N: Nextcloud data share unavailable.
    pause
    exit /b 1
)

if not exist "O:\." (
    echo ERROR: O: Nextcloud config share unavailable.
    pause
    exit /b 1
)

if not exist "P:\." (
    echo ERROR: P: Nextcloud exports share unavailable.
    pause
    exit /b 1
)

if not exist "Q:\." (
    echo ERROR: Q: Nextcloud application share unavailable.
    pause
    exit /b 1
)

echo All four server shares are available.
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

echo Before continuing, check:
echo   - Tailscale is connected.
echo   - Nextcloud desktop sync is Up to date.
echo   - No large transfers are running.
echo   - All four server shares are accessible.
echo.

choice /C YN /N /M "Ready to start the backup? (Y/N): "

if errorlevel 2 exit /b 0

REM Prepare Nextcloud

echo.
echo ==========================================
echo       PREPARING NEXTCLOUD SERVER
echo ==========================================
echo.

ssh -t "%SERVER%" "sudo /usr/local/sbin/nextcloud-restic-prepare"

set "PREP_RC=%ERRORLEVEL%"

if not "%PREP_RC%"=="0" (
    echo.
    echo ERROR: Server preparation failed.
    echo Attempting maintenance-mode recovery...
    echo.

    ssh -t "%SERVER%" "sudo /usr/local/sbin/nextcloud-restic-finish"

    echo.
    echo No Restic backup was started.
    echo Check the server before trying again.
    pause
    exit /b 1
)

REM Run Restic backup

echo.
echo ==========================================
echo          RUNNING RESTIC BACKUP
echo ==========================================
echo.

"%RESTIC%" -r "%REPO%" backup ^
    "D:\Nextcloud" ^
    "N:\." ^
    "O:\." ^
    "P:\." ^
    "Q:\." ^
    --exclude="D:\Nextcloud\.sync_*" ^
    --exclude="D:\Nextcloud\.nextcloudsync.log" ^
    --exclude="D:\Nextcloud\Desktop.ini" ^
    --exclude="Q:\data" ^
    --exclude="Q:\config"

set "BACKUP_RC=%ERRORLEVEL%"

REM Always attempt to finish the server workflow

echo.
echo ==========================================
echo       RESTORING NEXTCLOUD SERVICE
echo ==========================================
echo.

ssh -t "%SERVER%" "sudo /usr/local/sbin/nextcloud-restic-finish"

set "FINISH_RC=%ERRORLEVEL%"

REM Report backup result

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
    echo Check the Ubuntu server immediately.
    echo Run: sudo /usr/local/sbin/nextcloud-restic-finish
)

REM Show latest snapshot if backup succeeded

if "%BACKUP_RC%"=="0" (
    echo.
    echo Latest Restic snapshot:
    "%RESTIC%" -r "%REPO%" snapshots --latest 1
)

echo.
pause

if not "%BACKUP_RC%"=="0" exit /b 1
if not "%FINISH_RC%"=="0" exit /b 2

exit /b 0
