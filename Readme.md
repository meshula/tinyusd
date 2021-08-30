
**Tiny USD**

This isn't a tiny re-implementation of USD. This is a tutorial on creating the 
smallest possible viable USD program from scratch on Windows.

It skips building Hydra, as that introduces significant complexity to the build
process.

Prerequisites
-------------

- git
- cmake 3.20 or greater installed for the command line
- Visual Studio 2019

Building
--------

Shallow clone the USD dev branch into this project's packages directory:

```
cd tinyusd
mkdir packages
cd packages
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

Configure USD
-------------


Build USD
---------

Let's build USD into a clean installation directory, say /tmp/USD-install

```bat
python USD/build_scripts/build_usd.py --no-python --no-tools --no-usdview --draco --materialx /tmp/USD-install
```

Cherry pick the installation
----------------------------

we're going to copy /tmp/USD-install/plugin/usd/ to /tinyusd-build/bin/usd/
also `/tmp/USD-install/resources` to tinyusd-build/bin/resources
also `/tmp/USD-install/bin/*.dll` to tinyusd-build/bin
also `/tmp/USD-install/lib/*.dll` to tinyusd-build/bin


TinyUsd
-------
Make sure you have a c:\tmp directory.
When you run the program from the tinyusd\build\install\bin directory, it should 
create a simple USDA file:

```
c:\tmp\test.usda
```

The file will look like this:

```
#usda 1.0

def Cube "Box"
{
    float3 xformOp:scale = (5, 5, 5)
    uniform token[] xformOpOrder = ["xformOp:scale"]
}

```
