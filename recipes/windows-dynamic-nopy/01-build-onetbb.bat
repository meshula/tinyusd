@echo off
setlocal enabledelayedexpansion

REM TinyUSD OneTBB Build Script
REM Builds Intel OneTBB (Threading Building Blocks) dependency
REM Modified for new directory structure: sources in packages/, build in build-windows-dynamic-nopy/

REM Source environment setup
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
call "%SCRIPT_DIR%\env-setup.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

echo 🔧 Building OneTBB...

REM Change to packages directory for source
cd /d "%PROJECT_ROOT%\packages"

REM Download OneTBB if not already present
if not exist "oneTBB" (
    echo 📥 Downloading OneTBB 2022.2.0...
    curl -L https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2022.2.0.zip --output oneTBB-2022.2.0.zip
    if %errorlevel% neq 0 (
        echo ERROR: Failed to download OneTBB
        exit /b 1
    )
    
    REM Extract using PowerShell (available on all modern Windows)
    powershell -command "Expand-Archive -Path 'oneTBB-2022.2.0.zip' -DestinationPath '.'"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to extract OneTBB
        exit /b 1
    )
    
    ren oneTBB-2022.2.0 oneTBB
    del oneTBB-2022.2.0.zip
    echo ✓ OneTBB source downloaded to %PROJECT_ROOT%\packages\oneTBB
) else (
    echo ✓ OneTBB source already present at %TBB_SOURCE_DIR%
)

REM Create build directory at top level of build area
set TBB_BUILD_DIR=%USD_BUILD_DIR%\oneTBB-build
if not exist "%TBB_BUILD_DIR%" mkdir "%TBB_BUILD_DIR%"
cd /d "%TBB_BUILD_DIR%"

echo 🔨 Configuring OneTBB...
echo   Source: %TBB_SOURCE_DIR%
echo   Build:  %TBB_BUILD_DIR%
echo   Install: %USD_DEPS_INSTALL_DIR%

cmake "%TBB_SOURCE_DIR%" ^
    -DTBB_TEST=OFF ^
    -DTBB_STRICT=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%USD_DEPS_INSTALL_DIR%"

if %errorlevel% neq 0 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

echo 🔨 Building OneTBB...
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo 📦 Installing OneTBB...
cmake --install .
if %errorlevel% neq 0 (
    echo ERROR: Installation failed
    exit /b 1
)

echo ✓ OneTBB build complete!
echo    Source:    %TBB_SOURCE_DIR%
echo    Build:     %TBB_BUILD_DIR%
echo    Installed: %USD_DEPS_INSTALL_DIR%

REM Verify installation
if exist "%USD_DEPS_INSTALL_DIR%\lib" if exist "%USD_DEPS_INSTALL_DIR%\include\tbb" (
    echo ✓ OneTBB installation verified
) else (
    echo ❌ OneTBB installation verification failed
    exit /b 1
)