
# MacOS, CMake

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

## Toolchain
------------

- git
- cmake 3.26 or greater installed for the command line
- Xcode command line tools

## Building Dependencies
------------------------

### MacOS

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
