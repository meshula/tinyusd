@echo off
setlocal enabledelayedexpansion

REM TinyUSD OpenSubdiv Build Script
REM Builds Pixar OpenSubdiv dependency
REM Modified for new directory structure: sources in packages/, build in build-windows-dynamic-nopy/

REM Source environment setup
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
call "%SCRIPT_DIR%\env-setup.bat"
if %errorlevel% neq 0 exit /b %errorlevel%

echo 🔧 Building OpenSubdiv...

REM Change to packages directory for source
cd /d "%PROJECT_ROOT%\packages"

REM Download OpenSubdiv if not already present
if not exist "OpenSubdiv" (
    echo 📥 Downloading OpenSubdiv 3.6.1...
    curl -L https://github.com/PixarAnimationStudios/OpenSubdiv/archive/refs/tags/v3_6_1.zip --output OpenSubdiv-3.6.1.zip
    if %errorlevel% neq 0 (
        echo ERROR: Failed to download OpenSubdiv
        exit /b 1
    )
    
    REM Extract using PowerShell
    powershell -command "Expand-Archive -Path 'OpenSubdiv-3.6.1.zip' -DestinationPath '.'"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to extract OpenSubdiv
        exit /b 1
    )
    
    ren OpenSubdiv-3_6_1 OpenSubdiv
    del OpenSubdiv-3.6.1.zip
    echo ✓ OpenSubdiv source downloaded to %PROJECT_ROOT%\packages\OpenSubdiv
) else (
    echo ✓ OpenSubdiv source already present at %OPENSUBDIV_SOURCE_DIR%
)

REM Create build directory at top level of build area
set OPENSUBDIV_BUILD_DIR=%USD_BUILD_DIR%\OpenSubdiv-build
if not exist "%OPENSUBDIV_BUILD_DIR%" mkdir "%OPENSUBDIV_BUILD_DIR%"
cd /d "%OPENSUBDIV_BUILD_DIR%"

echo 🔨 Configuring OpenSubdiv...
echo   Source: %OPENSUBDIV_SOURCE_DIR%
echo   Build:  %OPENSUBDIV_BUILD_DIR%
echo   Install: %USD_DEPS_INSTALL_DIR%

cmake "%OPENSUBDIV_SOURCE_DIR%" ^
    -DNO_EXAMPLES=ON ^
    -DNO_TUTORIALS=ON ^
    -DNO_REGRESSION=ON ^
    -DNO_DOC=ON ^
    -DNO_OMP=ON ^
    -DNO_CUDA=ON ^
    -DNO_OPENCL=ON ^
    -DNO_CLEW=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DTBB_LOCATION="%USD_DEPS_INSTALL_DIR%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%USD_DEPS_INSTALL_DIR%"

if %errorlevel% neq 0 (
    echo ERROR: CMake configuration failed
    exit /b 1
)

echo 🔨 Building OpenSubdiv...
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    exit /b 1
)

echo 📦 Installing OpenSubdiv...
cmake --install .
if %errorlevel% neq 0 (
    echo ERROR: Installation failed
    exit /b 1
)

echo ✓ OpenSubdiv build complete!
echo    Source:    %OPENSUBDIV_SOURCE_DIR%
echo    Build:     %OPENSUBDIV_BUILD_DIR%
echo    Installed: %USD_DEPS_INSTALL_DIR%

REM Verify installation
if exist "%USD_DEPS_INSTALL_DIR%\lib" if exist "%USD_DEPS_INSTALL_DIR%\include\opensubdiv" (
    echo ✓ OpenSubdiv installation verified
) else (
    echo ❌ OpenSubdiv installation verification failed
    exit /b 1
)