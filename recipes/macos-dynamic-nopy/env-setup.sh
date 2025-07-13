#!/bin/bash

# TinyUSD Environment Setup Script
# Source this script from other build scripts to set up consistent environment variables
# Auto-configuring for build configuration based on script directory

echo "Setting up TinyUSD build environment..."

if ! command -v cmake &> /dev/null; then
    echo "ERROR: cmake not found. Please install cmake 3.26 or greater"
    return 1 2>/dev/null || exit 1
fi

if ! command -v git &> /dev/null; then
    echo "ERROR: git not found. Please install git"
    return 1 2>/dev/null || exit 1
fi

# Get the absolute path to this script's directory and derive build config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_CONFIG="$(basename "${SCRIPT_DIR}")"

# PROJECT_ROOT is two directories up from the scripts
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# New directory structure
export USD_SOURCE_DIR="${PROJECT_ROOT}/packages/USD"
export TBB_SOURCE_DIR="${PROJECT_ROOT}/packages/oneTBB"
export OPENSUBDIV_SOURCE_DIR="${PROJECT_ROOT}/packages/OpenSubdiv"

# Build directory (derived from script directory name)
export USD_BUILD_DIR="${PROJECT_ROOT}/build-${BUILD_CONFIG}"
export USD_INSTALL_DIR="${USD_BUILD_DIR}/install"

# Dependencies install directly to build directory, eliminating extra 'deps' layer
export USD_DEPS_INSTALL_DIR="${USD_BUILD_DIR}/install"

# Python environment detection (respects virtualenv/conda)
# Let Python itself report its configuration
if command -v python3 &> /dev/null; then
    export USD_PYTHON_EXE="$(command -v python3)"
    export USD_PYTHON_ROOT="$(python3 -c "import sys; print(sys.exec_prefix)")"
elif command -v python &> /dev/null; then
    # Check if 'python' is actually Python 3
    PYTHON_VERSION="$(python -c "import sys; print(sys.version_info[0])" 2>/dev/null || echo "unknown")"
    if [ "$PYTHON_VERSION" = "3" ]; then
        export USD_PYTHON_EXE="$(command -v python)"
        export USD_PYTHON_ROOT="$(python -c "import sys; print(sys.exec_prefix)")"
    else
        echo "ERROR: Python 3 required, but 'python' command points to Python $PYTHON_VERSION"
        echo "Please ensure python3 is available in your PATH"
        return 1 2>/dev/null || exit 1
    fi
else
    echo "ERROR: No Python interpreter found. Please install Python 3 or activate your virtual environment"
    return 1 2>/dev/null || exit 1
fi

# Report detected Python environment
PYTHON_VERSION_FULL="$(${USD_PYTHON_EXE} -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")"
PYTHON_ENV_TYPE="system"
if [ -n "$VIRTUAL_ENV" ]; then
    PYTHON_ENV_TYPE="virtualenv ($VIRTUAL_ENV)"
elif [ -n "$CONDA_DEFAULT_ENV" ]; then
    PYTHON_ENV_TYPE="conda ($CONDA_DEFAULT_ENV)"
fi

echo "✅ Python environment detected:"
echo "  Version: Python $PYTHON_VERSION_FULL"
echo "  Type: $PYTHON_ENV_TYPE"
echo "  Executable: $USD_PYTHON_EXE"
echo "  Root: $USD_PYTHON_ROOT"

# Create necessary directories
mkdir -p "${PROJECT_ROOT}/packages"
mkdir -p "${USD_BUILD_DIR}"
mkdir -p "${USD_INSTALL_DIR}"

# Display environment
echo "Environment configured:"
echo "  BUILD_CONFIG       = ${BUILD_CONFIG}"
echo "  PROJECT_ROOT       = ${PROJECT_ROOT}"
echo "  USD_SOURCE_DIR     = ${USD_SOURCE_DIR}"
echo "  TBB_SOURCE_DIR     = ${TBB_SOURCE_DIR}"
echo "  OPENSUBDIV_SOURCE_DIR = ${OPENSUBDIV_SOURCE_DIR}"
echo "  USD_BUILD_DIR      = ${USD_BUILD_DIR}"
echo "  USD_INSTALL_DIR    = ${USD_INSTALL_DIR}"
echo "  USD_DEPS_INSTALL_DIR = ${USD_DEPS_INSTALL_DIR}"
echo "  USD_PYTHON_EXE     = ${USD_PYTHON_EXE}"
echo ""

# Verify key requirements
if [ ! -d "${USD_SOURCE_DIR}" ]; then
    echo "INFO: USD source not found at ${USD_SOURCE_DIR}"
    echo "Will be downloaded to: ${PROJECT_ROOT}/packages/"
fi

echo "✅ Environment setup complete and verified"
