@echo off
setlocal EnableDelayedExpansion

title NutriVoice - Build Windows Installer

echo.
echo ============================================
echo   NutriVoice - Windows Installer Builder
echo ============================================
echo.

:: ── Step 1: Check Flutter ──────────────────────────────────────────────────
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter not found in PATH.
    echo         Install Flutter: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

:: ── Step 2: Enable Windows desktop target ──────────────────────────────────
echo [1/4] Enabling Windows desktop support...
flutter config --enable-windows-desktop >nul 2>&1

:: ── Step 3: Get packages ───────────────────────────────────────────────────
echo [2/4] Installing packages...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] flutter pub get failed.
    pause
    exit /b 1
)

:: ── Step 4: Build Flutter Windows release ─────────────────────────────────
echo [3/4] Building Flutter Windows release...
echo       (This may take 2-5 minutes on first build)
echo.
flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter build failed. See output above.
    pause
    exit /b 1
)

set BUILD_DIR=build\windows\x64\runner\Release
if not exist "%BUILD_DIR%\nutri_voice.exe" (
    echo [ERROR] Build output not found at %BUILD_DIR%
    echo         Check if the build completed successfully.
    pause
    exit /b 1
)

echo.
echo [OK] Flutter build complete.
echo      Output: %BUILD_DIR%
echo.

:: ── Step 5: Find Inno Setup ───────────────────────────────────────────────
set ISCC=""

:: Check common Inno Setup installation paths
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set ISCC="C:\Program Files\Inno Setup 6\ISCC.exe"
) else (
    where ISCC >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set ISCC=ISCC
    ) else (
        echo [ERROR] Inno Setup 6 not found.
        echo.
        echo  Please install Inno Setup 6 from:
        echo  https://jrsoftware.org/isdl.php
        echo.
        echo  After installing, re-run this script.
        echo.
        echo  Alternatively, open installer\setup.iss manually in Inno Setup.
        pause
        exit /b 1
    )
)

echo [4/4] Building installer with Inno Setup...
%ISCC% "installer\setup.iss"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Inno Setup compilation failed.
    pause
    exit /b 1
)

:: ── Done ───────────────────────────────────────────────────────────────────
echo.
echo ============================================
echo   SUCCESS!
echo ============================================
echo.
echo   Installer created:
echo   installer\NutriVoice_Setup.exe
echo.
echo   You can now:
echo   - Run the installer to test it
echo   - Distribute NutriVoice_Setup.exe to users
echo.
pause
