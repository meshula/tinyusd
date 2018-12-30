
**Tiny USD**

This isn't a tiny re-implementation of USD. This is a tutorial on creating the
smallest possible viable USD program from scratch on Windows.

There are two variants presented; one without Pixar's Hydra rendering engine, and
one with. The build is much quicker and simpler without Hydra, and is often not
needed, so that variant is presented first.

Prerequisites
-------------

- git
- cmake 3.11 or greater installed for the command line
- Visual Studio 2017

Building
--------

Clone the USD dev branch into this project's packages directory:

```
cd tinyusd
mkdir packages
cd packages
git clone https://github.com/PixarAnimationStudios/USD.git -b dev
```

Next, get a copy of boost. The latest version of boost has the least amount of
issues with the latest Visual Studio and Xcodes. Pixar's recommended boosts are
1.55 for linux, and 1.61 otherwise.

```
https://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.gz
https://downloads.sourceforge.net/project/boost/boost/1.61.0/boost_1_61_0.tar.gz
https://downloads.sourceforge.net/project/boost/boost/1.69.0/boost_1_69_0.tar.gz
```

boost is a large library that takes a long time to compile; in order to avoid this
detour, this tutorial skips two tools: sdfdump, and sdfilter, which require
boost program_options. If you need this, you'll need to build at least program_options.

Anyway, download and unzip the archive. This tutorial will only need the headers, so either copy the
boost folder containing the headers into packages, or copy the whole unpacked
directory. If you downloaded boost_1_69_0, the minimum necessary is to copy the
folder boost in the boost_1_69_0 folder to packages.

```
packages
 +--boost
      +-- accumulators
      +-- archive
      etc
```

Obtain Intel's TBB library. Grab it from the list of "assets" here:

https://github.com/01org/tbb/releases

Extract the archive. It will contain a folder with a name like tbb2019_20181203oss.
Move this folder into the packages directory.

```
packages
 +-- boost
      +-- accumulators
      +-- archive
      etc
 +-- tbb2019_20181203oss
```

Obtain a zlib archive, and unzip it.

https://github.com/madler/zlib/archive/v1.2.11.zip

```
packages
 +-- boost
      +-- accumulators
      +-- archive
      etc
 +-- tbb2019_20181203oss
 +-- zlib-1.2.11
```

Build it. These instructions are for Windows. In a Visual Studio x64 command shell:

```
cd zlib-1.2.11
mkdir build
cd build
cmake -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX="../install" ..
cmake --build . --config Release --target install
```

Make a build directory in the /tinyusd directory:

```
mkdir build
cd build
```

```
mkdir usd
cd usd
```

Configure USD
-------------

#Important

There is residual usage of boost by the tools sdfdump and sdfilter. Comment them out in USD/pxr/usd/bin/CMakeLists.txt
Remove the references to program_options in USD/cmake/defaults/Packages.cmake, i.e.:

```
    # --Boost
    find_package(Boost)
```

Configure the build from within the build/usd directory. In all the commands that follow,
replace PROJECT_DIR with a full path to your project root. In my case, PROJECT_DIR is c:/projects/

At this point, if you are intending to build Hydra, skip ahead to Building With Hydra.

```
cmake -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON -DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF -DPXR_BUILD_IMAGING=OFF -DPXR_ENABLE_GL_SUPPORT=OFF -DCMAKE_CXX_FLAGS="/Zm150" -DCMAKE_PREFIX_PATH=PROJECT_DIR/tinyusd/packages/tbb2019_20181203oss;PROJECT_DIR/tinyusd/packages/zlib-1.211/install;PROJECT_DIR/tinyusd/packages -DCMAKE_INSTALL_PREFIX=PROJECT_DIR/tinyusd/install -G "Visual Studio 15 2017 Win64" ../../packages/USD
```

Build USD
---------

I'm building on an older laptop, so I've specified three cores, /M:3.

```
cmake --build . --config Release --target install -- /M:3
```


Building with Hydra
-------------------

USD is quite usable without Hydra. Hydra is a useful reference renderer
visual validation in viewports and so on. Building Hydra is more
complicated because additional dependencies are introduced. The base procedure
is the same as for building USD, but before configuring USD, the additional
dependencies must also be satisfied.

Having completed all the previous steps, up to Configure USD, obtain and unpack glew into the packages folder.

```
https://downloads.sourceforge.net/project/glew/glew/2.0.0/glew-2.0.0-win32.zip
```
```
packages
 +-- boost
      +-- accumulators
      +-- archive
      etc
 +-- glew-2.1.0
      +-- bin
      etc
 +-- tbb2019_20181203oss
 +-- zlib-1.2.11
```

This leaves openexr and opensubdiv to be built. In the packages directory:

```
git clone https://github.com/openexr/openexr.git
cd openexr
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=PROJECT_DIR/tinyusd/install -G "Visual Studio 15 2017 Win64"  -DCMAKE_PREFIX_PATH=PROJECT_DIR/tinyusd/packages/zlib-1.211/install -DOPENEXR_BUILD_PYTHON_LIBS=OFF -DOPENEXR_ENABLE_TESTS=OFF ../
```
and build OpenEXR:
```
cmake --build . --config Release --target install -- /M:3
```
Okay, that was a piece of cake. Finally, we need OpenSubdiv. Once again, in the
packages directory:

```
git clone https://github.com/PixarAnimationStudios/OpenSubdiv.git
```

Now configure opensubdiv. Note that USD wants to dynamically link GLEW, so the
opensubdiv build must be forced to comply.

```
cd opensubdiv
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=PROJECT_DIR/tinyusd/install -G "Visual Studio 15 2017 Win64" -DGLEW_LIBRARY=PROJECT_DIR/tinyusd/packages/glew-2.1.0/lib/x64/glew32.lib -DGLEW_INCLUDE_DIR=PROJECT_DIR/tinyusd/packages/glew-2.1.0/include -DZLIB_INCLUDE_DIR=PROJECT_DIR/tinyusd/packages/zlib-1.211/install/include -DZLIB_LIBRARY=PROJECT_DIR/tinyusd/packages/zlib-1.211/install/lib/zlib.lib -DCMAKE_PREFIX_PATH=PROJECT_DIR/tinyusd/packages/zlib-1.211/install;PROJECT_DIR/tinyusd/packages/tbb2019_20181203oss -DNO_EXAMPLES=1 -DNO_TUTORIALS=1 -DNO_REGRESSION=1 -DNO_DOC=1 -DNO_OMP=1 ../
```
and build OpenSubdiv:
```
cmake --build . --config Release --target install -- /M:3
```

Configure USD. In the tinyusd/build/usd directory:

```
cmake ../../packages/USD -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON -DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF -DPXR_BUILD_IMAGING=ON -DPXR_ENABLE_GL_SUPPORT=ON -DPXR_ENABLE_PTEX_SUPPORT=OFF -DCMAKE_CXX_FLAGS="/Zm150" -DZLIB_INCLUDE_DIR=PROJECT_DIR/tinyusd/packages/zlib-1.211/install/include -DZLIB_LIBRARY=PROJECT_DIR/tinyusd/packages/zlib-1.211/install/lib/zlib.lib -DTBB_INCLUDE_DIRS=PROJECT_DIR/tinyusd/packages/tbb2019_20181203oss/include -DTBB_tbb_LIBRARY_DEBUG=PROJECT_DIR/tinyusd/packages/tbb2019_20181203oss/lib/intel64/vc14/tbb_debug.lib -DTBB_tbb_LIBRARY_RELEASE=PROJECT_DIR/tinyusd/packages/tbb2019_20181203oss/lib/intel64/vc14/tbb.lib -DCMAKE_PREFIX_PATH=PROJECT_DIR/tinyusd/packages/tbb2019_20181203oss;PROJECT_DIR/tinyusd/packages/zlib-1.211/install;PROJECT_DIR/tinyusd/packages/glew-2.1.0;PROJECT_DIR/tinyusd/packages;PROJECT_DIR/tinyusd/install -DCMAKE_INSTALL_PREFIX=PROJECT_DIR/tinyusd/install -G "Visual Studio 15 2017 Win64"
```

and build it:
```
cmake --build . --config Release --target install -- /M:3
```

Finish up the installation
--------------------------

In a little while, tinyusd/build/install will contain the USD installation. The
USD install puts the runtime DLLs in the lib directory, so copy the libusd_ms.dll
to the bin directory, and
the usd folder from the lib directory to the tinyusd/build/install/bin directory.

When built without the imaging packages, there is no runtime dependency on boost,
so the only other dlls that need to be copied are tbb.dll and zlib1.dll, from
the bin folders in the tbb and zlib package directories.


TinyUsd
-------

CMake isn't super fun to deal with, so for the purposes of this tutorial,
please go clone LabCMake as a sister directory to tinyusd. LabCMake is here:

```
cd ..\..\..
git clone https://github.com/meshula/LabCMake.git
```

It doesn't have any build steps, it just needs to be available at the relative location.

i.e.

```
Projects/
   LabCMake/
   tinyusd/
```

Go back into the build directory we made earlier, and create a tinyusd directory,
and cd into it. Then, configure the cmake build files. Once again, make sure
the INSTALL_PREFIX and TOOLCHAIN variables are pointed appropriately.

```
cd tinyusd\build
mkdir tinyusd
cd tinyusd
cmake -G "Visual Studio 15 2017 Win64" ../.. -DCMAKE_INSTALL_PREFIX=C:/projects/tinyusd/build/install
-DCMAKE_PREFIX_PATH=C:/projects/tinyusd/build/install -DCMAKE_TOOLCHAIN_FILE=C:/projects/tinyusd/packages/vcpkg/scripts/buildsystems/vcpkg.cmake
```

Build tinyusd.

```
cmake --build . --config Release --target install -- /M:2
```

Make sure you have a c:\tmp directory.
When you run the program from the tinyusd\build\install\bin directory, it should
create a simple USDA file:

```
c:\tmp\test.usda
```

As a sanity check, the generated file should have the following contents:

```
#usda 1.0

def Cube "Box"
{
    float3 xformOp:scale = (5, 5, 5)
    uniform token[] xformOpOrder = ["xformOp:scale"]
}

```
