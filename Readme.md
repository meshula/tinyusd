
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

1. Enter build path:
```
cd build
```

2. Generate the build products
```
./run_here.sh
```

3. Open Project in Xcode
```
open tinyusd.xcodeproj
```

4. Fix Team
- Select the main project `tinyusd` and open "Build Settings"
- Under "Signing" -> "Development Team"
- Select your dev team

5. Select target `ALL BUILD` and build everything

Double check your work
----------------------

NOTE: THE END GOAL IS TO DISPLAY A MESH ON IOS WITH EITHER METAL OR SCENEKIT
THAT CODE IS NOT YET WRITTEN


TODO
----

 - [X] Add other boost submodules as required
 - [X] Create a top level cmake file that uses the toolchain file to build the submodules
 - [X] Resolve build issues in USD
 - [ ] Patch USD to find and initialize the plugins (otherwise nothing will be loadable by USD)
 - [ ] Add a Framework target to the USD CMake system to create an encapsulated USD.framework for macos, and ios
 - [ ] Create a simple usd viewing application for ios that simply displays the hierarchy of files in a loaded USD file
 - [ ] Create an importer for mesh and other geometry to translate USD data in ModelIO data structures
 - [ ] Create a usd viewing application for ios that visualizes the contents of a USD file with Metal or SceneKit

