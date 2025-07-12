
## Environment Setup
--------------------

Before building USD, set up your environment variables according to your platform. You can customize these paths to match your specific setup.

### Environment Variables Overview
- `USD_SOURCE_DIR`: Location of the USD source code
- `USD_DEPS_DIR`: Directory for building and installing dependencies
- `USD_BUILD_DIR`: Directory for building USD
- `USD_INSTALL_DIR`: Directory where USD will be installed
- `USD_PYTHON_ROOT`: Base directory of your Python installation
- `USD_PYTHON_EXE`: Path to the Python executable

### MacOS Environment
```.sh
# Set up environment variables for paths, adjust as necessary.
export USD_SOURCE_DIR=~/dev/OpenUSD               # USD source code location
export USD_DEPS_DIR=/var/tmp/usd-test/__deps      # Dependencies directory
export USD_BUILD_DIR=/var/tmp/usd-build           # USD build directory
export USD_INSTALL_DIR=${USD_BUILD_DIR}/install   # USD installation directory
export USD_PYTHON_ROOT=/usr/local/bin             # Python installation directory
export USD_PYTHON_EXE=${USD_PYTHON_ROOT}/python   # Python executable

# Create necessary directories
mkdir -p ${USD_DEPS_DIR}
mkdir -p ${USD_DEPS_DIR}/install
mkdir -p ${USD_BUILD_DIR}
```

### Windows Environment
```.bat
:: Set up environment variables for paths
:: Adjust these paths according to your setup
set USD_SOURCE_DIR=%USERPROFILE%\dev\OpenUSD      :: USD source code location
set USD_DEPS_DIR=%USERPROFILE%\dev\deps           :: Dependencies directory
set USD_BUILD_DIR=%USERPROFILE%\dev\build\usd     :: USD build directory
set USD_INSTALL_DIR=%USD_BUILD_DIR%\install       :: USD installation directory
set USD_PYTHON_ROOT=%LOCALAPPDATA%\Programs\Python\Python39  :: Python installation directory
set USD_PYTHON_EXE=%USD_PYTHON_ROOT%\python.exe   :: Python executable

:: Create necessary directories
mkdir %USD_DEPS_DIR%
mkdir %USD_DEPS_DIR%\install
mkdir %USD_BUILD_DIR%
```

### Linux Environment
```.sh
# Set up environment variables for paths
export USD_SOURCE_DIR=~/dev/OpenUSD               # USD source code location
export USD_DEPS_DIR=~/deps                        # Dependencies directory
export USD_BUILD_DIR=~/build/usd                  # USD build directory
export USD_INSTALL_DIR=~/install/USD              # USD installation directory

# Python path - adjust based on your distribution and Python version
# For system Python:
export USD_PYTHON_ROOT=/usr/bin
export USD_PYTHON_EXE=${USD_PYTHON_ROOT}/python3
# For conda environments (uncomment if using conda):
#export USD_PYTHON_ROOT=$CONDA_PREFIX
#export USD_PYTHON_EXE=${USD_PYTHON_ROOT}/bin/python

# Create necessary directories
mkdir -p ${USD_DEPS_DIR}
mkdir -p ${USD_DEPS_DIR}/install
mkdir -p ${USD_BUILD_DIR}
```

## Toolchain
------------

- git
- cmake 3.26 or greater installed for the command line
- For MacOS: Xcode command line tools

## Building Dependencies
------------------------

### MacOS and Linux Prerequisites

```.sh
# Change to dependencies directory
cd ${USD_DEPS_DIR}

# OneTBB
curl -L https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.9.0.zip --output oneTBB-2021.9.0.zip
unzip oneTBB-2021.9.0.zip && mv oneTBB-2021.9.0/ oneTBB
cd oneTBB && mkdir -p build && cd build
cmake .. -DTBB_TEST=OFF -DTBB_STRICT=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${USD_DEPS_DIR}/install
cmake --build . --config Release && cmake --install .
cd ../..

# OpenSubdiv
curl -L https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v3_6_0.zip --output OpenSubdiv.3.6.0.zip
unzip OpenSubdiv.3.6.0.zip && mv OpenSubdiv-3_6_0/ OpenSubdiv
cd OpenSubdiv && mkdir build && cd build
cmake .. -DNO_OPENGL=ON -DNO_EXAMPLES=ON -DNO_TUTORIALS=ON -DNO_REGRESSION=ON -DNO_DOC=ON -DNO_OMP=ON -DNO_CUDA=ON -DNO_OPENCL=ON -DNO_DX=ON -DNO_TESTS=ON -DNO_GLEW=ON -DNO_GLFW=ON -DNO_PTEX=ON -DNO_TBB=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${USD_DEPS_DIR}/install
cmake --build . --config Release && cmake --install .
cd ../..
```

## Building USD with CMake
--------------------------

### MacOS Build (With Python)

```.sh
cmake ${USD_SOURCE_DIR} -G Xcode -DCMAKE_INSTALL_PREFIX=${USD_INSTALL_DIR} -DPython3_ROOT="${USD_PYTHON_ROOT}" -DPython3_EXECUTABLE="${USD_PYTHON_EXE}"
```

### MacOS Build (No Python)

Note that we may point to the python for tools to use even though we are building USD without python runtime support.

First, delete cmake/modules/FindOpenSubdiv.cmake as it is not compatible with the cmake config file OpenSubdiv installs.

```.sh
cd ${USD_BUILD_DIR}

cmake ${USD_SOURCE_DIR} -G Xcode -DCMAKE_INSTALL_PREFIX=${USD_INSTALL_DIR} -DPython3_ROOT="${USD_PYTHON_ROOT}" -DPython3_EXECUTABLE="${USD_PYTHON_EXE}" -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DCMAKE_PREFIX_PATH=${USD_DEPS_DIR}/install -DTBB_ROOT=${USD_DEPS_DIR}/install
```

## Building USD with build_usd.py
---------------------------------

### MacOS Dynamic Framework (No Python)

```.sh
# Build USD without Python support
${USD_PYTHON_EXE} ${USD_SOURCE_DIR}/build_scripts/build_usd.py \
    --generator Xcode \
    --tests \
    --no-python \
    --no-openimageio \
    --opencolorio \
    --build-variant relwithdebuginfo \
    ${USD_BUILD_DIR} \
    | grep -v -e "note: Run script build phase" \
              -e "RegisterExecutionPolicyException" \
              -e "PhaseScriptExecution" \
              -e "ClangStatCache" \
              -e "    cd" \
              -e "note: Removed stale file" \
              -e "ProcessProductPackaging"
```

### MacOS Dynamic Framework (With Python)

```.sh
# Build USD with Python support
${USD_PYTHON_EXE} ${USD_SOURCE_DIR}/build_scripts/build_usd.py \
    --generator Xcode \
    --tests \
    --no-openimageio \
    --opencolorio \
    --build-variant relwithdebuginfo \
    ${USD_BUILD_DIR} \
    | grep -v -e "note: Run script build phase" \
              -e "RegisterExecutionPolicyException" \
              -e "PhaseScriptExecution" \
              -e "ClangStatCache" \
              -e "    cd" \
              -e "note: Removed stale file" \
              -e "ProcessProductPackaging"
```

### Windows Build

```.bat
:: Build USD without Python support
%USD_PYTHON_EXE% %USD_SOURCE_DIR%\build_scripts\build_usd.py ^
    --no-openimageio ^
    --opencolorio ^
    --no-python ^
    --build-variant=relwithdebuginfo ^
    %USD_BUILD_DIR%
```

### Ubuntu Build

First, install required system dependencies:
```.sh
sudo apt install libx11-dev libxt-dev libxrandr-dev
```

Set up Python environment:
1. Create a venv or conda environment
2. Install required packages:
   ```sh
   pip install PySide6 pyopengl
   ```

Build USD without Python support:
```.sh
${USD_PYTHON_EXE} ${USD_SOURCE_DIR}/build_scripts/build_usd.py \
    --no-python \
    ${USD_INSTALL_DIR}
```
Note: If build fails, modify `src/oneTBB-2020.3.1/build/common.inc` to add detection for "linux" in addition to "Linux"

Build USD with Python support (requires Python development libraries):
```.sh
${USD_PYTHON_EXE} ${USD_SOURCE_DIR}/build_scripts/build_usd.py \
    ${USD_INSTALL_DIR}
```
Note: Ensure your conda environment includes the appropriate Python development libraries (e.g., python3.12.a)

## Additional Configuration
---------------------------

### Xcode Debugging Setup
To configure Xcode for USD development:
1. Edit Scheme > Arguments
2. Add a USD_INSTALL_DIR environment variable corresponding to the set up above.
2. Add the PXR_PLUGINPATH_NAME variable so plugins will be discovered:
   ```.sh
   PXR_PLUGINPATH_NAME=${USD_INSTALL_DIR}/lib/usd
   ```


## Double check your work
-------------------------

There is an executable in the bin directory called sdfdump. Running it
should result in the executable describing its input arguments, without any complaints of missing dylibs.

## TinyUsd
----------

Go back into the packages directory we made earlier, and create a tinyusd-build directory,
and cd into it. 

```sh
mkdir tinyusd-build && cd tinyusd-build
```

Then, configure the cmake build files. Once again, make sure
the INSTALL_PREFIX and TOOLCHAIN variables are pointed appropriately.

```sh
cmake -G "Xcode" ../.. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=$USD_INSTALL_DIR
```

Build tinyusd.

```sh
cmake --build . --config Release --target install
```

Haven't got the rpath installation set up correctly in the cmake file yet, so go to the bin directory, and add it.

```sh
cd ../bin
install_name_tool -add_rpath ../lib tinyusd
```

Now, run tinyusd.

```sh
./tinyusd
```

Sanity check that tinyusd generated a file named test.usd, containing the following:

```usd
#usda 1.0

def Cube "Box"
{
    float3 xformOp:scale = (5, 5, 5)
    uniform token[] xformOpOrder = ["xformOp:scale"]
}

```
