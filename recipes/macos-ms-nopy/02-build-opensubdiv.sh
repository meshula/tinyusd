#!/bin/bash

# TinyUSD OpenSubdiv Build Script
# Builds Pixar OpenSubdiv dependency
# Modified for new directory structure: sources in packages/, build in build-macos-dynamic-nopy/

set -e  # Exit on any error

# Source environment setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env-setup.sh"

echo "🔧 Building OpenSubdiv..."

# Change to packages directory for source
cd "${PROJECT_ROOT}/packages"

# Download OpenSubdiv if not already present
if [ ! -d "OpenSubdiv" ]; then
    echo "📥 Downloading OpenSubdiv 3.6.1..."
    curl -L https://github.com/PixarAnimationStudios/OpenSubdiv/archive/refs/tags/v3_6_1.zip --output OpenSubdiv-3.6.1.zip
    unzip OpenSubdiv-3.6.1.zip
    mv OpenSubdiv-3_6_1/ OpenSubdiv
    rm OpenSubdiv-3.6.1.zip
    echo "✅ OpenSubdiv source downloaded to ${PROJECT_ROOT}/packages/OpenSubdiv"
else
    echo "✅ OpenSubdiv source already present at ${OPENSUBDIV_SOURCE_DIR}"
fi

# Create build directory at top level of build area
OPENSUBDIV_BUILD_DIR="${USD_BUILD_DIR}/OpenSubdiv-build"
mkdir -p "${OPENSUBDIV_BUILD_DIR}"
cd "${OPENSUBDIV_BUILD_DIR}"

echo "🔨 Configuring OpenSubdiv..."
echo "  Source: ${OPENSUBDIV_SOURCE_DIR}"
echo "  Build:  ${OPENSUBDIV_BUILD_DIR}"
echo "  Install: ${USD_DEPS_INSTALL_DIR}"

cmake "${OPENSUBDIV_SOURCE_DIR}" \
    -DNO_EXAMPLES=ON \
    -DNO_TUTORIALS=ON \
    -DNO_REGRESSION=ON \
    -DNO_DOC=ON \
    -DNO_OMP=ON \
    -DNO_CUDA=ON \
    -DNO_OPENCL=ON \
    -DNO_CLEW=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DTBB_LOCATION="${USD_DEPS_INSTALL_DIR}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${USD_DEPS_INSTALL_DIR}"

echo "🔨 Building OpenSubdiv..."
cmake --build . --config Release

echo "📦 Installing OpenSubdiv..."
cmake --install .

echo "✅ OpenSubdiv build complete!"
echo "   Source:    ${OPENSUBDIV_SOURCE_DIR}"
echo "   Build:     ${OPENSUBDIV_BUILD_DIR}"
echo "   Installed: ${USD_DEPS_INSTALL_DIR}"

# Verify installation
if [ -d "${USD_DEPS_INSTALL_DIR}/lib" ] && [ -d "${USD_DEPS_INSTALL_DIR}/include/opensubdiv" ]; then
    echo "✅ OpenSubdiv installation verified"
else
    echo "❌ OpenSubdiv installation verification failed"
    exit 1
fi