@echo off
setlocal enabledelayedexpansion

REM TinyUSD Comprehensive Build Script
REM Runs the complete build process from dependencies to final executable
REM Modified for new directory structure: sources in packages/, build in build-windows-dynamic-nopy/

set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

echo 🚀 Starting TinyUSD complete build process...
echo    Script directory: %SCRIPT_DIR%
echo    Project will be built in: ..\..\build-windows-dynamic-nopy\
echo    Source packages will be in: ..\..\packages\
echo.

REM Step 1: OneTBB
echo 🔧 Step 1/4: Building OneTBB...
call "%SCRIPT_DIR%\01-build-onetbb.bat"
if %errorlevel% neq 0 (
    echo ERROR: OneTBB build failed
    exit /b %errorlevel%
)
echo.

REM Step 2: OpenSubdiv
echo 🔧 Step 2/4: Building OpenSubdiv...
call "%SCRIPT_DIR%\02-build-opensubdiv.bat"
if %errorlevel% neq 0 (
    echo ERROR: OpenSubdiv build failed
    exit /b %errorlevel%
)
echo.

REM Step 3: USD
echo 🔧 Step 3/4: Building USD...
call "%SCRIPT_DIR%\03-build-usd.bat"
if %errorlevel% neq 0 (
    echo ERROR: USD build failed
    exit /b %errorlevel%
)
echo.

REM Step 4: TinyUSD
echo 🔧 Step 4/4: Building TinyUSD...
call "%SCRIPT_DIR%\04-build-tinyusd.bat"
if %errorlevel% neq 0 (
    echo ERROR: TinyUSD build failed
    exit /b %errorlevel%
)
echo.

REM Source environment to get paths for summary
call "%SCRIPT_DIR%\env-setup.bat"

echo 🎉 Complete build process finished successfully!
echo.
echo 📋 Build Summary:
echo    Project Root:    %PROJECT_ROOT%
echo    Source Packages: %PROJECT_ROOT%\packages\
echo    Build Directory: %USD_BUILD_DIR%\
echo    Shared Install:  %USD_INSTALL_DIR%\
echo    TinyUSD:         %USD_BUILD_DIR%\bin\tinyusd.exe
echo.
echo 🧪 To test TinyUSD:
echo    cd /d "%USD_BUILD_DIR%\bin"
echo    set PATH=%USD_INSTALL_DIR%\bin;%USD_INSTALL_DIR%\lib;%USD_DEPS_INSTALL_DIR%\bin;%USD_DEPS_INSTALL_DIR%\lib;%%PATH%%
echo    tinyusd.exe