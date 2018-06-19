
**Tiny USD**

This isn't a tiny re-implementation of USD. This is a tutorial on creating the 
smallest possible viable USD program from scratch on Windows.

It skips building Hydra, as that introduces significant complexity to the build
process.

Prerequisites
-------------

- git
- cmake 3.11 or greater installed for the command line
- Visual Studio 2017

Building
--------

Shallow clone the USD dev branch into this project's packages directory:

```
cd tinyusd
mkdir packages
cd packages
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

Install vcpkg. This only takes a couple of minutes:

```
git clone --depth 1 https://github.com/Microsoft/vcpkg
cd vcpkg
.\bootstrap-vcpkg.bat
```

Next, build boost. This takes a while, might be a good moment to file an issue on USD requesting
the elimination of boost as a dependency ;) We're only going to install the bits
USD needs, so bear with...

```
vcpkg install boost-assign:x64-windows boost-atomic:x64-windows boost-date-time:x64-windows boost-filesystem:x64-windows boost-format:x64-windows boost-multi-index:x64-windows boost-program-options:x64-windows boost-thread:x64-windows boost-vmd:x64-windows
```

A little bit of other boost will be installed as a result, but don't worry about it.
At least it's not all of boost which takes a really long time to build.

Install the remaining dependencies:

```
vcpkg install tbb:x64-windows zlib:x64-windows
cd ..
```

Make a build directory in the /tinyusd directory:

```
mkdir build
cd build
mkdir usd
cd usd
```

Finally, build USD. We are going to build USD without python or the Imaging modules, as these
introduce significant build complexity. We're also going to skip the Alembic
plugin. Adding it is a simple matter of installing the libraries via vcpkg.

First, configure the build, from within the build/usd directory.

In the command below, replace the PREFIX and TOOLCHAIN variable values with
appropriate paths.

```
cmake ^
-DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON ^
-DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF ^
-DPXR_BUILD_ALEMBIC_PLUGIN=OFF ^
-DPXR_BUILD_IMAGING=OFF  ^
-DCMAKE_CXX_FLAGS="/Zm150" ^
-DCMAKE_INSTALL_PREFIX=C:\projects\tinyusd\build\install ^
-DCMAKE_TOOLCHAIN_FILE=C:\projects\tinyusd\packages\vcpkg\scripts\buildsystems\vcpkg.cmake ^
-G "Visual Studio 15 2017 Win64" ^
../../packages/USD
```

Now, build USD. I'm building on an older laptop, so I've specified two cores, /M:2.

```
cmake --build . --config Release --target install -- /M:2
```

Finish up the installation: 

In a little while, tinyusd/build/install will contain the USD installation. The
USD install puts the runtime DLLs in the lib directory, so copy the libusd_ms.dll
to the bin directory, and
the usd folder from the lib directory to the tinyusd/build/install/bin directory.

When built without the imaging packages, there is no runtime dependency on boost,
so the only other dll that needs to be copied is tbb.dll, from 
tinyusd/packages/installed/x64-windows/bin/tbb.dll


Double check your work:

There is an executable in the bin directory called sdfdump.exe. Running it
should result in the executable running, without any complaints of missing dlls.

On to tinyusd:

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
cmake -G "Visual Studio 15 2017 Win64" ../.. -DCMAKE_INSTALL_PREFIX=C:\projects\tinyusd\build\install -DCMAKE_TOOLCHAIN_FILE=C:\projects\tinyusd\packages\vcpkg\scripts\buildsystems\vcpkg.cmake
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
