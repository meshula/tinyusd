
# Tiny USD

A tutorial on creating the smallest possible viable USD program, using
the dev branch of the official usd distribution.

Note that this currently highly work in progress, the mac recipe is the only
one fully worked for cmake. The windows recipe still uses build_usd.py, and 
ubuntu remains a struggle.

Help wanted!

# USD Build Club

- [MacOS, dynamic, no python](recipes/macos-dynamic-nopy/) ✅
- [MacOS, dynamic, python](recipes/macos-dynamic-py/) ✅
- [MacOS, static monolithic, no python](recipes/macos-ms-nopy/) ✅
- [MacOS, static, no python](recipes/macos-static-nopy/) 🚧
- [Windows, dynamic, no python](recipes/windows-dynamic-nopy/) 🚧

## Reference

[MacOS, cmake](recipes/macos-cmake.md) - Build USD with CMake from first principles
[MacOS, cmake, static-monolithic](recipes/macos-cmake-static-monolithic.md) - Build USD with CMake from first principles
[Everything else](recipes/README.md) - Using build_usd.py, Windows, Linux

# License

BSD
