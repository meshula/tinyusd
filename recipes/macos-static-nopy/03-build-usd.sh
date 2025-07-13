#!/bin/bash

# TinyUSD USD Build Script
# Builds USD library with dependencies
# Modified for new directory structure: sources in packages/, build in build-macos-dynamic-nopy/

set -e  # Exit on any error

# Source environment setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env-setup.sh"

echo "🔧 Building USD..."

# Download USD if not already present
cd "${PROJECT_ROOT}/packages"
if [ ! -d "USD" ]; then
    echo "📥 Downloading USD..."
    git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
    echo "✅ USD source downloaded to ${PROJECT_ROOT}/packages/USD"
else
    echo "✅ USD source already present at ${USD_SOURCE_DIR}"
fi

# Check dependencies are installed
if [ ! -d "${USD_DEPS_INSTALL_DIR}/lib" ]; then
    echo "❌ Dependencies not found. Please run 01-build-onetbb.sh and 02-build-opensubdiv.sh first"
    exit 1
fi

# Create USD build directory at top level of build area
USD_CMAKE_BUILD_DIR="${USD_BUILD_DIR}/usd-build"
mkdir -p "${USD_CMAKE_BUILD_DIR}"
cd "${USD_CMAKE_BUILD_DIR}"

# Note from recipe: delete cmake/modules/FindOpenSubdiv.cmake as it's not compatible 
# with the cmake config file OpenSubdiv installs
FIND_OPENSUBDIV="${USD_SOURCE_DIR}/cmake/modules/FindOpenSubdiv.cmake"
if [ -f "${FIND_OPENSUBDIV}" ]; then
    echo "🔧 Removing incompatible FindOpenSubdiv.cmake..."
    rm "${FIND_OPENSUBDIV}"
fi

echo "🔨 Configuring USD (No Python Support)..."
echo "  Source: ${USD_SOURCE_DIR}"
echo "  Build:  ${USD_CMAKE_BUILD_DIR}"
echo "  Install: ${USD_INSTALL_DIR}"

cmake "${USD_SOURCE_DIR}" \
    -G Xcode \
    -DCMAKE_INSTALL_PREFIX="${USD_INSTALL_DIR}" \
    -DPython3_ROOT="${USD_PYTHON_ROOT}" \
    -DPython3_EXECUTABLE="${USD_PYTHON_EXE}" \
    -DPXR_ENABLE_PYTHON_SUPPORT=OFF \
    -DCMAKE_PREFIX_PATH="${USD_DEPS_INSTALL_DIR}" \
    -DBUILD_SHARED_LIBS=OFF \
    -DPXR_BUILD_MONOLITHIC=OFF \
    -DTBB_ROOT="${USD_DEPS_INSTALL_DIR}"

echo "🔨 Building USD..."
cmake --build . --config Release

echo "📦 Installing USD..."
cmake --install . --config Release

echo "✅ USD build complete!"
echo "   Source:    ${USD_SOURCE_DIR}"
echo "   Build:     ${USD_CMAKE_BUILD_DIR}"
echo "   Installed: ${USD_INSTALL_DIR}"

# Verify installation - check for sdfdump executable
SDFDUMP="${USD_INSTALL_DIR}/bin/sdfdump"
if [ -f "${SDFDUMP}" ]; then
    echo "✅ USD installation verified - sdfdump found"
    echo "🧪 Testing sdfdump..."
    "${SDFDUMP}" --help | head -3
else
    echo "❌ USD installation verification failed - sdfdump not found"
    exit 1
fi