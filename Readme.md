
**Tiny USD**

This is the iOS fork of TinyUSD. It builds and packages USD for iOS, and
also has special sauce for compiling dependencies that aren't normally 
available as part of the iOS SDK.

It skips building Hydra, as there is currently no Metal build, and Hydra
otherwise requires OpenGL4, or an independent rendering system such as
Embree.

Prerequisites
-------------

- git
- cmake 3.14 or greater installed for the command line
- latest Xcode and iOS SDKs

Getting the Code
----------------

```sh
git clone --recursive https://github.com/meshula.com/tinyusd.git -b ios
```

If you cloned without recursive, follow up the clone with:
```sh
git submodule update --init
```

Building
--------
First, configure the build, from within your build/usd.

NOTE: THIS IS A NONFUNCTIONAL PLACEHOLDER, WE WILL USE THE TOOLCHAIN FILE FROM THE submodules DIRECTORY
```
cmake -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON -DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF -DCMAKE_CXX_FLAGS="/Zm150" -DCMAKE_INSTALL_PREFIX=c:\projects\tinyusd\install\install -DCMAKE_TOOLCHAIN_FILE=c:\projects\tinyusd\install\vcpkg\scripts\buildsystems\vcpkg.cmake -G "Visual Studio 15 2017 Win64" ../../packages/USD
```

NOTE: UNTIL THE ROOT CMAKE FILE IS CORRECT, THIS WILL NOT WORK
```
cmake --build . --config Release --target install
```

Double check your work
----------------------

NOTE: THE END GOAL IS TO DISPLAY A MESH ON IOS WITH EITHER METAL OR SCENEKIT
THAT CODE IS NOT YET WRITTEN


TODO
----

 - [ ] Add other boost submodules as required
 - [ ] Create a top level cmake file that uses the toolchain file to build the submodules
 - [ ] Resolve build issues in USD
 - [ ] Patch USD to find and initialize the plugins (otherwise nothing will be loadable by USD)
 - [ ] Add a Framework target to the USD CMake system to create an encapsulated USD.framework for macos, and ios
 - [ ] Create a simple usd viewing application for ios that simply displays the hierarchy of files in a loaded USD file
 - [ ] Create an importer for mesh and other geometry to translate USD data in ModelIO data structures
 - [ ] Create a usd viewing application for ios that visualizes the contents of a USD file with Metal or SceneKit

