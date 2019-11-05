#!/bin/bash
cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=`pwd`/../submodules/ios-cmake/ios.toolchain.cmake -DPLATFORM=OS64COMBINED -DENABLE_VISIBILITY=1 -DCMAKE_INSTALL_PREFIX=`pwd`/local -DDEPLOYMENT_TARGET=10.3
