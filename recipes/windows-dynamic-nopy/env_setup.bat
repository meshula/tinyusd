@echo off
REM TinyUSD Environment Setup Script
REM Call this script from other build scripts to set up consistent environment variables
REM Auto-configuring for build configuration based on script directory

echo Setting up TinyUSD build environment...

REM Check for cmake
cmake --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: cmake not found. Please install cmake 3.26 or greater
    exit /b 1
)

REM Check for git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: git not found. Please install git
    exit /b 1
)

REM Get the absolute path to this script's directory and derive build config
set SCRIPT_DIR=%~dp0
REM Remove trailing backslash
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
for %%I in ("%SCRIPT_DIR%") do set BUILD_CONFIG=%%~nxI

REM PROJECT_ROOT is two directories up from the scripts
for %%I in ("%SCRIPT_DIR%\..\..") do set PROJECT_ROOT=%%~fI

REM New directory structure
set USD_SOURCE_DIR=%PROJECT_ROOT%\packages\USD
set TBB_SOURCE_DIR=%PROJECT_ROOT%\packages\oneTBB
set OPENSUBDIV_SOURCE_DIR=%PROJECT_ROOT%\packages\OpenSubdiv

REM Build directory (derived from script directory name)
set USD_BUILD_DIR=%PROJECT_ROOT%\build-%BUILD_CONFIG%
set USD_INSTALL_DIR=%USD_BUILD_DIR%\install

REM Dependencies install directly to build directory, eliminating extra 'deps' layer
set USD_DEPS_INSTALL_DIR=%USD_BUILD_DIR%\install

REM Python environment detection
REM Try python3 first
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set USD_PYTHON_EXE=python3
    for /f "tokens=*" %%i in ('python3 -c "import sys; print(sys.exec_prefix)"') do set USD_PYTHON_ROOT=%%i
) else (
    REM Try python
    python --version >nul 2>&1
    if %errorlevel% equ 0 (
        REM Check if 'python' is actually Python 3
        for /f "tokens=*" %%i in ('python -c "import sys; print(sys.version_info[0])" 2^>nul') do set PYTHON_VERSION=%%i
        if "!PYTHON_VERSION!"=="3" (
            set USD_PYTHON_EXE=python
            for /f "tokens=*" %%i in ('python -c "import sys; print(sys.exec_prefix)"') do set USD_PYTHON_ROOT=%%i
        ) else (
            echo ERROR: Python 3 required, but 'python' command points to Python !PYTHON_VERSION!
            echo Please ensure python3 is available in your PATH
            exit /b 1
        )
    ) else (
        echo ERROR: No Python interpreter found. Please install Python 3 or activate your virtual environment
        exit /b 1
    )
)

REM Report detected Python environment
for /f "tokens=*" %%i in ('%USD_PYTHON_EXE% -c "import sys; print(''.join(map(str, sys.version_info[:3])))"') do set PYTHON_VERSION_FULL=%%i
set PYTHON_ENV_TYPE=system
if defined VIRTUAL_ENV (
    set PYTHON_ENV_TYPE=virtualenv (%VIRTUAL_ENV%)
)
if defined CONDA_DEFAULT_ENV (
    set PYTHON_ENV_TYPE=conda (%CONDA_DEFAULT_ENV%)
)

echo ✓ Python environment detected:
echo   Version: Python %PYTHON_VERSION_FULL%
echo   Type: %PYTHON_ENV_TYPE%
echo   Executable: %USD_PYTHON_EXE%
echo   Root: %USD_PYTHON_ROOT%

REM Create necessary directories
if not exist "%PROJECT_ROOT%\packages" mkdir "%PROJECT_ROOT%\packages"
if not exist "%USD_BUILD_DIR%" mkdir "%USD_BUILD_DIR%"
if not exist "%USD_INSTALL_DIR%" mkdir "%USD_INSTALL_DIR%"

REM Display environment
echo Environment configured:
echo   BUILD_CONFIG       = %BUILD_CONFIG%
echo   PROJECT_ROOT       = %PROJECT_ROOT%
echo   USD_SOURCE_DIR     = %USD_SOURCE_DIR%
echo   TBB_SOURCE_DIR     = %TBB_SOURCE_DIR%
echo   OPENSUBDIV_SOURCE_DIR = %OPENSUBDIV_SOURCE_DIR%
echo   USD_BUILD_DIR      = %USD_BUILD_DIR%
echo   USD_INSTALL_DIR    = %USD_INSTALL_DIR%
echo   USD_DEPS_INSTALL_DIR = %USD_DEPS_INSTALL_DIR%
echo   USD_PYTHON_EXE     = %USD_PYTHON_EXE%
echo.

REM Verify key requirements
if not exist "%USD_SOURCE_DIR%" (
    echo INFO: USD source not found at %USD_SOURCE_DIR%
    echo Will be downloaded to: %PROJECT_ROOT%\packages\
)

echo ✓ Environment setup complete and verified
