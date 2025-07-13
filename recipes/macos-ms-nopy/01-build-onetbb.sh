#!/bin/bash

# TinyUSD OneTBB Build Script
# Builds Intel OneTBB (Threading Building Blocks) dependency
# Modified for new directory structure: sources in packages/, build in build-macos-dynamic-nopy/

set -e  # Exit on any error

# Source environment setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env-setup.sh"

echo "🔧 Building OneTBB..."

# Change to packages directory for source
cd "${PROJECT_ROOT}/packages"

# Download OneTBB if not already present
if [ ! -d "oneTBB" ]; then
    echo "📥 Downloading OneTBB 2022.2.0..."
    curl -L https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2022.2.0.zip --output oneTBB-2022.2.0.zip
    unzip oneTBB-2022.2.0.zip
    mv oneTBB-2022.2.0/ oneTBB
    rm oneTBB-2022.2.0.zip
    echo "✅ OneTBB source downloaded to ${PROJECT_ROOT}/packages/oneTBB"
else
    echo "✅ OneTBB source already present at ${TBB_SOURCE_DIR}"
fi

# Create build directory at top level of build area
TBB_BUILD_DIR="${USD_BUILD_DIR}/oneTBB-build"
mkdir -p "${TBB_BUILD_DIR}"
cd "${TBB_BUILD_DIR}"

echo "🔨 Configuring OneTBB..."
echo "  Source: ${TBB_SOURCE_DIR}"
echo "  Build:  ${TBB_BUILD_DIR}"
echo "  Install: ${USD_DEPS_INSTALL_DIR}"

cmake "${TBB_SOURCE_DIR}" \
    -DTBB_TEST=OFF \
    -DTBB_STRICT=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${USD_DEPS_INSTALL_DIR}"

echo "🔨 Building OneTBB..."
cmake --build . --config Release

echo "📦 Installing OneTBB..."
cmake --install .

echo "✅ OneTBB build complete!"
echo "   Source:    ${TBB_SOURCE_DIR}"
echo "   Build:     ${TBB_BUILD_DIR}"
echo "   Installed: ${USD_DEPS_INSTALL_DIR}"

# Verify installation
if [ -d "${USD_DEPS_INSTALL_DIR}/lib" ] && [ -d "${USD_DEPS_INSTALL_DIR}/include/tbb" ]; then
    echo "✅ OneTBB installation verified"
else
    echo "❌ OneTBB installation verification failed"
    exit 1
fi