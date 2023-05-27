
# Tiny USD

A tutorial on creating the smallest possible viable USD program, using
the dev branch of the official usd distribution.

In the spirit of minimalism, it skips Hydra, and Python bindings.

## Prerequisites
-------------

- git
- cmake 3.26 or greater installed for the command line
- Xcode command line tools, tested with Apple Clang 14

## Building
--------

Shallow clone the USD dev branch into this project's packages directory:

```sh
cd tinyusd
mkdir packages
cd packages
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

### boost
Fetch boost and unarchive it. Boost will not be built, the headers as is are sufficient.

```sh
./get_boost.sh
```

### tbb
Fetch and build tbb. In the root directory:

```sh
./get_tbb.sh
```

### OpenSubdiv
If you are building USD with Hydra, you'll need OpenSubdiv.

```sh
./get_opensubdiv.sh
```

## Configure USD
-------------

Once again, starting in the packages directory:

```sh
mkdir usd-build;cd usd-build
```

We are going to build USD without python, as python adds complexity,
by requiring that boost python be built.

First, configure the build, from within the usd-build directory.

In the command below, replace the PREFIX and TOOLCHAIN variable values with
appropriate paths.


### with Hydra
```sh
cmake -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON -DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=..  -G "Xcode" ../USD
```

### without Hydra
```sh
cmake -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON -DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF -DPXR_BUILD_IMAGING=OFF -DCMAKE_INSTALL_PREFIX=..  -G "Xcode" ../USD
```

## Build USD
---------

```sh
cmake --build . --config Release --target install
```

## Finish up the installation
--------------------------

In a little while, packages/lib will contain the libusd_ms.dylib, and packages/include will have the headers, packages/bin will have sdfdump and sdffilter.

## Double check your work
----------------------

There is an executable in the bin directory called sdfdump. Running it
should result in the executable describing its input arguments, without any complaints of missing dylibs.

## TinyUsd
-------

Go back into the packages directory we made earlier, and create a tinyusd-build directory,
and cd into it. 

```sh
mkdir tinyusd-build;cd tinyusd-build
```

Then, configure the cmake build files. Once again, make sure
the INSTALL_PREFIX and TOOLCHAIN variables are pointed appropriately.

```sh
cmake -G "Xcode" ../.. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=..
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
