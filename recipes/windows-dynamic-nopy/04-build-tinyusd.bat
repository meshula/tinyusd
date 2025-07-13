@echo off
setlocal enabledelayedexpansion

REM TinyUSD Application Build Script
REM Builds the minimal TinyUSD executable
REM Modified for new directory structure: sources in packages/, build in build-windows-dynamic-nopy/

REM Source environment setup
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
call "%SCRIPT_DIR%\env-setup.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

echo 🔧 Building TinyUSD application...

REM Check that USD is installed
if not exist "%USD_INSTALL_DIR%\bin\sdfdump.exe" (
    echo ❌ USD not found. Please run 03-build-usd.bat first
    exit /b 1
)

REM Create TinyUSD build directory at top level of build area
set TINYUSD_CMAKE_BUILD_DIR=%USD_BUILD_DIR%\tinyusd-build
if not exist "%TINYUSD_CMAKE_BUILD_DIR%" mkdir "%TINYUSD_CMAKE_BUILD_DIR%"
cd /d "%TINYUSD_CMAKE_BUILD_DIR%"

echo 🔨 Configuring TinyUSD...
echo   Source: %PROJECT_ROOT%
echo   Build:  %TINYUSD_CMAKE_BUILD_DIR%
echo   Install: %USD_BUILD_DIR%

cmake "%PROJECT_ROOT%" ^
    -G "Visual Studio 17 2022" ^
    -A x64 ^
    -DCMAKE_INSTALL_PREFIX="%USD_BUILD_DIR%" ^
    -DCMAKE_PREFIX_PATH="%USD_INSTALL_DIR%;%USD_DEPS_INSTALL_DIR%"

if %errorlevel% neq 0 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

echo 🔨 Building TinyUSD...
cmake --build . --config Release --target install
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo 📦 Installing TinyUSD...
REM Copy the executable to our build directory bin
if not exist "%USD_BUILD_DIR%\bin" mkdir "%USD_BUILD_DIR%\bin"
copy "bin\Release\tinyusd.exe" "%USD_BUILD_DIR%\bin\"
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy executable
    exit /b 1
)

REM Note: Windows doesn't need rpath fixing like macOS, but we need to ensure
REM that the DLLs are in the PATH or same directory as the executable

echo ✓ TinyUSD build complete!
echo    Source:     %PROJECT_ROOT%
echo    Build:      %TINYUSD_CMAKE_BUILD_DIR%
echo    Executable: %USD_BUILD_DIR%\bin\tinyusd.exe

REM Test the executable
echo 🧪 Testing TinyUSD...
cd /d "%USD_BUILD_DIR%\bin"

REM Set PATH to include our lib directory for DLLs
set PATH=%USD_INSTALL_DIR%\bin;%USD_INSTALL_DIR%\lib;%USD_DEPS_INSTALL_DIR%\bin;%USD_DEPS_INSTALL_DIR%\lib;%PATH%

if exist "tinyusd.exe" (
    echo Running tinyusd...
    tinyusd.exe
    if %errorlevel% equ 0 (
        REM Check if cube.usda was created
        if exist "cube.usda" (
            echo ✓ TinyUSD test successful - cube.usda created
            echo 📄 Contents of cube.usda:
            type cube.usda
        ) else (
            echo ❌ TinyUSD test failed - cube.usda not created
            exit /b 1
        )
    ) else (
        echo ❌ TinyUSD execution failed with error %errorlevel%
        exit /b 1
    )
) else (
    echo ❌ TinyUSD executable not found
    exit /b 1
)