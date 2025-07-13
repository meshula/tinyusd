@echo off
setlocal enabledelayedexpansion

REM TinyUSD USD Build Script
REM Builds USD library with dependencies
REM Modified for new directory structure: sources in packages/, build in build-windows-dynamic-nopy/

REM Source environment setup
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
call "%SCRIPT_DIR%\env-setup.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

echo 🔧 Building USD...

REM Download USD if not already present
cd /d "%PROJECT_ROOT%\packages"
if not exist "USD" (
    echo 📥 Downloading USD...
    git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
    if %errorlevel% neq 0 (
        echo ERROR: Failed to clone USD repository
        exit /b 1
    )
    echo ✓ USD source downloaded to %PROJECT_ROOT%\packages\USD
) else (
    echo ✓ USD source already present at %USD_SOURCE_DIR%
)

REM Check dependencies are installed
if not exist "%USD_DEPS_INSTALL_DIR%\lib" (
    echo ❌ Dependencies not found. Please run 01-build-onetbb.bat and 02-build-opensubdiv.bat first
    exit /b 1
)

REM Create USD build directory at top level of build area
set USD_CMAKE_BUILD_DIR=%USD_BUILD_DIR%\usd-build
if not exist "%USD_CMAKE_BUILD_DIR%" mkdir "%USD_CMAKE_BUILD_DIR%"
cd /d "%USD_CMAKE_BUILD_DIR%"

REM Note from recipe: delete cmake/modules/FindOpenSubdiv.cmake as it's not compatible
REM with the cmake config file OpenSubdiv installs
set FIND_OPENSUBDIV=%USD_SOURCE_DIR%\cmake\modules\FindOpenSubdiv.cmake
if exist "%FIND_OPENSUBDIV%" (
    echo 🔧 Removing incompatible FindOpenSubdiv.cmake...
    del "%FIND_OPENSUBDIV%"
)

echo 🔨 Configuring USD (No Python Support)...
echo   Source: %USD_SOURCE_DIR%
echo   Build:  %USD_CMAKE_BUILD_DIR%
echo   Install: %USD_INSTALL_DIR%

REM Use Visual Studio generator for Windows
cmake "%USD_SOURCE_DIR%" ^
    -G "Visual Studio 17 2022" ^
    -A x64 ^
    -DCMAKE_INSTALL_PREFIX="%USD_INSTALL_DIR%" ^
    -DPython3_ROOT="%USD_PYTHON_ROOT%" ^
    -DPython3_EXECUTABLE="%USD_PYTHON_EXE%" ^
    -DPXR_ENABLE_PYTHON_SUPPORT=OFF ^
    -DCMAKE_PREFIX_PATH="%USD_DEPS_INSTALL_DIR%" ^
    -DBUILD_SHARED_LIBS=ON ^
    -DPXR_BUILD_MONOLITHIC=OFF ^
    -DTBB_ROOT="%USD_DEPS_INSTALL_DIR%"

if %errorlevel% neq 0 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

echo 🔨 Building USD...
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo 📦 Installing USD...
cmake --install . --config Release
if %errorlevel% neq 0 (
    echo ERROR: Installation failed
    exit /b 1
)

echo ✓ USD build complete!
echo    Source:    %USD_SOURCE_DIR%
echo    Build:     %USD_CMAKE_BUILD_DIR%
echo    Installed: %USD_INSTALL_DIR%

REM Verify installation - check for sdfdump executable
set SDFDUMP=%USD_INSTALL_DIR%\bin\sdfdump.exe
if exist "%SDFDUMP%" (
    echo ✓ USD installation verified - sdfdump found
    echo 🧪 Testing sdfdump...
    "%SDFDUMP%" --help | findstr /C:"usage"
) else (
    echo ❌ USD installation verification failed - sdfdump not found
    exit /b 1
)