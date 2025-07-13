#!/bin/bash

# TinyUSD Comprehensive Build Script
# Runs the complete build process from dependencies to final executable
# Modified for new directory structure: sources in packages/, build in build-macos-dynamic-nopy/

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting TinyUSD complete build process..."
echo "   Script directory: ${SCRIPT_DIR}"
echo "   Project will be built in: ../../build-macos-dynamic-nopy/"
echo "   Source packages will be in: ../../packages/"
echo ""

# Step 1: OneTBB
echo "🔧 Step 1/4: Building OneTBB..."
"${SCRIPT_DIR}/01-build-onetbb.sh"
echo ""

# Step 2: OpenSubdiv  
echo "🔧 Step 2/4: Building OpenSubdiv..."
"${SCRIPT_DIR}/02-build-opensubdiv.sh"
echo ""

# Step 3: USD
echo "🔧 Step 3/4: Building USD..."
"${SCRIPT_DIR}/03-build-usd.sh"
echo ""

# Step 4: TinyUSD
echo "🔧 Step 4/4: Building TinyUSD..."
"${SCRIPT_DIR}/04-build-tinyusd.sh"
echo ""

# Source environment to get paths for summary
source "${SCRIPT_DIR}/env-setup.sh"

echo "🎉 Complete build process finished successfully!"
echo ""
echo "📋 Build Summary:"
echo "   Project Root:    ${PROJECT_ROOT}"
echo "   Source Packages: ${PROJECT_ROOT}/packages/"
echo "   Build Directory: ${USD_BUILD_DIR}/"
echo "   Shared Install:  ${USD_INSTALL_DIR}/"
echo "   TinyUSD:         ${USD_BUILD_DIR}/bin/tinyusd"
echo ""
echo "🧪 To test TinyUSD:"
echo "   cd ${USD_BUILD_DIR}/bin"
echo "   ./tinyusd"
echo ""
echo "✅ TinyUSD build system ready!"