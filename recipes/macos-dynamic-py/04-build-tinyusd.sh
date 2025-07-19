#!/bin/bash

# TinyUSD Application Build Script
# Builds the minimal TinyUSD executable
# Modified for new directory structure: sources in packages/, build in build-macos-dynamic-nopy/

set -e  # Exit on any error

# Source environment setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env-setup.sh"

echo "🔧 Building TinyUSD application..."

# Check that USD is installed
if [ ! -f "${USD_INSTALL_DIR}/bin/sdfdump" ]; then
    echo "❌ USD not found. Please run 03-build-usd.sh first"
    exit 1
fi

# Create TinyUSD build directory at top level of build area
TINYUSD_CMAKE_BUILD_DIR="${USD_BUILD_DIR}/tinyusd-build"
mkdir -p "${TINYUSD_CMAKE_BUILD_DIR}"
cd "${TINYUSD_CMAKE_BUILD_DIR}"

echo "🔨 Configuring TinyUSD..."
echo "  Source: ${PROJECT_ROOT}"
echo "  Build:  ${TINYUSD_CMAKE_BUILD_DIR}"
echo "  Install: ${USD_BUILD_DIR}"

# DBUILD_SHARED_LIBS is set to ON to ensure dynamic linking to USD libraries
cmake "${PROJECT_ROOT}" \
    -G "Xcode" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="${USD_BUILD_DIR}" \
    -DCMAKE_PREFIX_PATH="${USD_INSTALL_DIR};${USD_DEPS_INSTALL_DIR}"

echo "🔨 Building TinyUSD..."
cmake --build . --config Release --target install

echo "📦 Installing TinyUSD..."
# Copy the executable to our build directory bin
mkdir -p "${USD_BUILD_DIR}/bin"
cp bin/Release/tinyusd "${USD_BUILD_DIR}/bin/"

# Fix rpath as mentioned in the recipe
cd "${USD_BUILD_DIR}/bin"
echo "🔧 Fixing rpath for tinyusd..."
install_name_tool -add_rpath "../lib" tinyusd

# Re-sign the executable after rpath modification
echo "🔏 Re-signing executable after rpath modification..."
codesign --force --sign - tinyusd

echo "✅ TinyUSD build complete!"
echo "   Source:     ${PROJECT_ROOT}"
echo "   Build:      ${TINYUSD_CMAKE_BUILD_DIR}"
echo "   Executable: ${USD_BUILD_DIR}/bin/tinyusd"

# Test the executable
echo "🧪 Testing TinyUSD..."
if [ -f "./tinyusd" ]; then
    echo "Running tinyusd..."
    ./tinyusd
    
    # Check if cube.usda was created
    if [ -f "./cube.usda" ]; then
        echo "✅ TinyUSD test successful - cube.usda created"
        echo "📄 Contents of cube.usda:"
        cat cube.usda
    else
        echo "❌ TinyUSD test failed - cube.usda not created"
        exit 1
    fi
else
    echo "❌ TinyUSD executable not found"
    exit 1
fi
