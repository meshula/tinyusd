
**Tiny USD**

This isn't a tiny re-implementation of USD. This is a tutorial on creating the 
smallest possible viable USD program, using C++, from scratch on macOS.

It skips building Hydra and the Python bindings, as that introduces 
significant complexity to the build process.

Prerequisites
-------------

- git
- cmake 3.11 or greater installed for the command line
- Xcode command line tools

Building
--------

Shallow clone the USD dev branch into this project's packages directory:

```
cd tinyusd
mkdir packages
cd packages
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

Next, fetch boost and build it. In the packages directory:

```
curl -# -L -o boost_1_61_0.tgz https://downloads.sourceforge.net/project/boost/boost/1.61.0/boost_1_61_0.tar.gz
tar -zxvf boost_1_61_0.tgz
cd boost_1_61_0
./bootstrap.sh
./b2 --prefix="../" --build-dir="build" address-model=64 link=static runtime-link=static threading=multi variant=release toolset=clang install --with-program_options
```

--with-system isn't strictly needed, but otherwise b2 will attempt to build everything. Maybe there's a b2 option to only copy headers?

build boost. This takes a long time, even though it's just headers to copy. Sigh. -

Next, fetch and build tbb. In the packages directory:

```
curl -# -L -o tbb_2017_U2.tgz https://github.com/01org/tbb/archive/2017_U2.tar.gz
tar -zxvf tbb_2017_U2.tgz
cd tbb_2017_U2
make -j4
cp build/*_release/libtbb*.* ../lib/
cp -r include/serial/ ../include/serial
cp -r include/tbb/ ../include/tbb
```


Configure USD
-------------

Once again, starting in the packages directory:

```
mkdir usd-build;cd usd-build
```

We are going to build USD without python, as python
introduces significant build complexity.

First, configure the build, from within the usd-build directory.

In the command below, replace the PREFIX and TOOLCHAIN variable values with
appropriate paths.

```
cmake -DPXR_ENABLE_PYTHON_SUPPORT=OFF -DPXR_BUILD_MONOLITHIC=ON -DPXR_BUILD_DOCUMENTATION=OFF -DPXR_BUILD_TESTS=OFF -DPXR_BUILD_IMAGING=OFF -DCMAKE_INSTALL_PREFIX=..  -G "Xcode" ../USD
```

Build USD
---------

```
cmake --build . --config Release --target install
```

Finish up the installation
--------------------------

In a little while, packages/lib will contain the libusd_ms.dylib, and packages/include will have the headers, packages/bin will have sdfdump and sdffilter.

Double check your work
----------------------

There is an executable in the bin directory called sdfdump. Running it
should result in the executable describing its input arguments, without any complaints of missing dylibs.

TinyUsd
-------

Go back into the packages directory we made earlier, and create a tinyusd-build directory,
and cd into it. 

```
mkdir tinyusd-build;cd tinyusd-build
```

Then, configure the cmake build files. Once again, make sure
the INSTALL_PREFIX and TOOLCHAIN variables are pointed appropriately.

```
cmake -G "Xcode" ../.. -DCMAKE_INSTALL_PREFIX=.. -DCMAKE_PREFIX_PATH=..
```

Build tinyusd.

```
cmake --build . --config Release --target install
```

Haven't got the rpath installation set up correctly in the cmake file yet, so go to the bin directory, and add it.

```
cd ../bin
install_name_tool -add_rpath ../lib tinyusd
```

Now, run tinyusd.

```
./tinyusd
```

Sanity check that tinyusd generated a file named test.usd, containing the following:

```
#usda 1.0

def Cube "Box"
{
    float3 xformOp:scale = (5, 5, 5)
    uniform token[] xformOpOrder = ["xformOp:scale"]
}

```
