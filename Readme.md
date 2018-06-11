
**Tiny USD**

This isn't a tiny re-implementation of USD. This is a tutorial on creating the 
smallest possible viable USD program from scratch on Windows.

It skips building Hydra, as that introduces significant complexity to the build
process.

##Shallow clone the USD dev branch into this project's packages directory.

```
cd packages
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

##Install vcpkg.

This only takes a couple of minutes.

```
git clone --depth 1 https://github.com/Microsoft/vcpkg
cd vcpkg
.\bootstrap-vcpkg.bat
```

## build boost

This takes a while, might be a good moment to file an issue on USD requesting
the elimination of boost as a dependency ;) We're only going to install the bits
USD needs, so bear with...

```
vcpkg install boost-assign:x64-windows
vcpkg install boost-atomic:x64-windows
vcpkg install boost-date-time:x64-windows
vcpkg install boost-filesystem:x64-windows
vcpkg install boost-format:x64-windows
vcpkg install boost-multi-index:x64-windows
vcpkg install boost-program-options:x64-windows
vcpkg install boost-thread:x64-windows
vcpkg install boost-vmd:x64-windows
```

A little bit of other boost will be installed as a result, but don't worry about it.
At least it's not all of boost which takes a really long time to build.

## install the remaining dependencies

```
vcpkg install tbb:x64-windows
vcpkg install zlib:x64-windows
```

##make a build directory.
```
mkdir build
cd build
mkdir usd
cd usd
```

##build USD

We are going to build USD without python or the Imaging modules, as these
introduce significant build complexity. We're also going to skip the Alembic
plugin. Adding it is a simple matter of installing the libraries via vcpkg.

First, configure the build, from within the build/usd directory.

```
cmake ^
-DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON ^
-DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF ^
-DPXR_BUILD_ALEMBIC_PLUGIN=OFF ^
-DPXR_BUILD_IMAGING=OFF  ^
-DCMAKE_CXX_FLAGS="/Zm150" ^
-DCMAKE_INSTALL_PREFIX=c:\projects\meshula\tinyusd\build\install ^
-DCMAKE_TOOLCHAIN_FILE=C:\projects\meshula\tinyusd\packages\vcpkg\scripts\buildsystems\vcpkg.cmake ^
-G "Visual Studio 15 2017 Win64" ^
../../packages/USD
```

Now, build USD. I'm building on an older laptop, so I've specified two cores, /M:2.

```
cmake --build . --config Release --target install -- /M:2
```

##Finish up the installation

In a little while, tinyusd/build/install will contain the USD installation. The
USD install puts the runtime DLLs in the lib directory, so copy the dlls, and
the usd folder from the lib directory to the tinyusd/build/install/bin directory.

Also, copy the dlls from tinyusd/packages/vcpkg/installed/x64-windows/bin to
the tinyusd/build/install/bin directory.

##Double check your work

There is an executable in the bin directory called sdfdump.exe. Running it
should result in the executable running, without any complaints of missing dlls.

##On to tinyusd

CMake isn't super fun to deal with, so for the purposes of this tutorial,
please go clone LabCMake as a sister directory to tinyusd. LabCMake is here:

```
https://github.com/meshula/LabCMake.git
```

It doesn't have any build steps, it just needs to be available at the relative location.

i.e.

```
Projects/
   LabCMake/
   tinyusd/
```

Go into the build directory we made earlier, and create a tinyuusd directory,
and cd into it. Then, configure the cmake build files, and build the Release 
build, or the MinRelDbg build, either using
cmake (see above), or by opening the sln file in Visual Studio and building in
the usual way.

```
cmake -G "Visual Studio 15 2017 Win64" ../..
```

Make sure you have a c:\tmp directory.
When you run the program, it should create a simple USDA file:

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
