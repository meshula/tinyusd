
# MacOS, CMake - TinyUSD Build Recipe

## Overview
-----------

This recipe provides a streamlined approach to building USD and TinyUSD on macOS using automated build scripts. The process is broken into four sequential scripts that handle dependencies, USD compilation, and the final TinyUSD executable.

## Build Convention
-------------------

This recipe follows the **build-* folder convention**:
- All build artifacts go into `build-macos-cmake-dynamic/` directory
- Dependencies are built in `build-macos-cmake-dynamic/deps/`
- USD is installed to `build-macos-cmake-dynamic/deps/install/`
- Final binaries are placed in `build-macos-cmake-dynamic/bin/`

## Environment Setup
--------------------

The build environment is automatically configured by `env-setup.sh`, which sets up all necessary paths based on the project structure:

### Key Environment Variables (Auto-configured)
- `USD_SOURCE_DIR`: `./packages/USD` (USD source code location)
- `USD_DEPS_DIR`: `./build-macos-cmake-dynamic/deps` (Dependencies directory)
- `USD_BUILD_DIR`: `./build-macos-cmake-dynamic` (Build root directory)
- `USD_INSTALL_DIR`: `./build-macos-cmake-dynamic/deps/install` (USD installation)
- `USD_PYTHON_EXE`: System Python3 executable (auto-detected)

### Prerequisites Check
The environment setup automatically verifies:
- USD source code exists in `packages/USD/`
- CMake 3.26+ is installed
- Git is available
- Python3 is available

## Prerequisites
----------------

- **git** - For cloning USD source
- **cmake 3.26+** - Build system (command line tools)
- **Xcode command line tools** - Native compiler toolchain
- **Python3** - USD tools (automatically detected)

### USD Source Setup
```sh
# Clone USD source (if not already done)
cd packages
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

## Automated Build Process
---------------------------

The build process is automated through four sequential scripts in the `build-macos-cmake-dynamic/` directory:

### Step 1: Build OneTBB (Threading Library)
```sh
./build-macos-cmake-dynamic/01-build-onetbb.sh
```

**What it does:**
- Downloads OneTBB 2021.9.0 from GitHub
- Configures with optimized settings (no tests, Release mode)
- Builds and installs to dependencies directory
- Verifies installation integrity

### Step 2: Build OpenSubdiv (Subdivision Library)
```sh
./build-macos-cmake-dynamic/02-build-opensubdiv.sh
```

**What it does:**
- Downloads OpenSubdiv 3.6.0 from Pixar GitHub
- Configures with minimal dependencies (no OpenGL, examples, tests)
- Builds and installs alongside OneTBB
- Verifies installation integrity

### Step 3: Build USD Library
```sh
./build-macos-cmake-dynamic/03-build-usd.sh
```

**What it does:**
- Removes incompatible `FindOpenSubdiv.cmake` (conflicts with OpenSubdiv's config)
- Configures USD with:
  - **No Python runtime support** (`-DPXR_ENABLE_PYTHON_SUPPORT=OFF`)
  - **Xcode generator** for native macOS development
  - **Dependency integration** (OneTBB, OpenSubdiv)
  - **Python tools support** (for USD command-line utilities)
- Builds USD in Release configuration
- Installs USD libraries and tools
- **Verifies installation** by testing `sdfdump` executable

### Step 4: Build TinyUSD Application
```sh
./build-macos-cmake-dynamic/04-build-tinyusd.sh
```

**What it does:**
- Configures TinyUSD using the project's `CMakeLists.txt`
- Links against the USD installation and dependencies
- Builds the minimal USD application
- **Fixes rpath** for proper library loading
- **Tests the executable** by running it and verifying `test.usd` output


## Complete Build Sequence
---------------------------

To build everything from scratch:

```sh
# Run all build steps in sequence
./build-macos-cmake-dynamic/01-build-onetbb.sh
./build-macos-cmake-dynamic/02-build-opensubdiv.sh
./build-macos-cmake-dynamic/03-build-usd.sh
./build-macos-cmake-dynamic/04-build-tinyusd.sh
```

### Key Modifications Made

1. **Environment Setup** (`env-setup.sh`):
   - Modified `USD_INSTALL_DIR` to use deps/install structure
   - Added automatic Python detection
   - Integrated with build-* folder convention

2. **CMakeLists.txt Improvements**:
   - Modern CMake target usage (`TBB::tbb`)
   - Proper USD library integration
   - Clean build/install separation

3. **Automated Dependency Resolution**:
   - Each script verifies prerequisites
   - Consistent error handling and status reporting
   - Integrated verification steps

### Xcode Development Setup
For Xcode debugging:
1. Edit Scheme > Arguments
2. Add environment variables:
   ```sh
   USD_INSTALL_DIR=${PROJECT_DIR}/build-macos-cmake-dynamic/deps/install
   PXR_PLUGINPATH_NAME=${USD_INSTALL_DIR}/lib/usd
   ```


## Verification
---------------

### USD Installation Check
After step 3, verify USD is working:
```sh
./build-macos-cmake-dynamic/deps/install/bin/sdfdump --help
```
This should display sdfdump usage without library errors.

### TinyUSD Application Test
After step 4, the build script automatically tests the application:
```sh
cd build-macos-cmake-dynamic/bin
./tinyusd
```

**Expected output file** (`test.usd`):
```usd
#usda 1.0

def Cube "Box"
{
    float3 xformOp:scale = (5, 5, 5)
    uniform token[] xformOpOrder = ["xformOp:scale"]
}
```

## Troubleshooting
------------------

### Common Issues

1. **Python not found**: The env-setup.sh script auto-detects Python3
2. **Missing USD source**: Run `git clone` in packages/ directory
3. **CMake version**: Ensure CMake 3.26+ is installed
4. **Library path issues**: The build scripts handle rpath automatically

### Clean Rebuild
To start fresh:
```sh
rm -rf build-macos-cmake-dynamic/deps
rm -rf build-macos-cmake-dynamic/usd-build
rm -rf build-macos-cmake-dynamic/tinyusd-build
```

### Manual Environment
If you need to run commands manually, source the environment:
```sh
source ./build-macos-cmake-dynamic/env-setup.sh
```
