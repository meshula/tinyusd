
cmake_minimum_required(VERSION 3.14)
project(tinyusd)

SET(TBB_BUILD_TESTS OFF CACHE BOOL "Build TBB tests and enable testing infrastructure" FORCE)
SET(TBB_BUILD_SHARED OFF CACHE BOOL "Build TBB shared library" FORCE)
add_subdirectory(submodules/tbb)

set(CMAKE_MODULE_PATH 
    ${CMAKE_CURRENT_SOURCE_DIR}/submodules/USD/cmake/defaults
    ${CMAKE_CURRENT_SOURCE_DIR}/submodules/USD/cmake/macros
    ${CMAKE_CURRENT_SOURCE_DIR}/submodules/USD/cmake/modules
)

# Set up variables for USD's find_package(Boost) to use tinyusd's local copy
set(Boost_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/submodules/boost-1_65_1")
set(Boost_INCLUDE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/submodules/boost-1_65_1"
    CACHE FILEPATH "Boost include directory")
set(Boost_LIBRARY_DIRS "")
set(Boost_LIBRARIES "")

# Same, for tbb
#set(TBB_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/submodules/tbb/include")
#set(TBB_INCLUDE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/submodules/tbb/include"
#    CACHE FILEPATH "TBB include directory")
#set(TBB_LIBRARY_DIRS "")
#set(TBB_LIBRARIES"")

set(PYTHON_EXECUTABLE /usr/bin/python)
set(PXR_BUILD_TESTS OFF CACHE BOOL "Build tests" FORCE)
set(PXR_BUILD_IMAGING OFF CACHE BOOL "Build imaging components" FORCE)
set(PXR_BUILD_USDVIEW OFF CACHE BOOL "Build usdview" FORCE)
set(PXR_ENABLE_GL_SUPPORT OFF CACHE BOOL "Enable GL based components" FORCE)
set(PXR_ENABLE_PYTHON_SUPPORT OFF CACHE BOOL "Enable Python components" FORCE)
set(PXR_ENABLE_HDF5_SUPPORT OFF CACHE BOOL "Enable HDF5 backednd for Alembic" FORCE)
set(PXR_ENABLE_PTEX_SUPPORT OFF CACHE BOOL "Enable Ptex" FORCE)
set(BUILD_SHARED_LIBRARIES OFF CACHE BOOL "Build shared libraries" FORCE)
set(PXR_BUILD_MONOLITHIC ON CACHE BOOL "Build monolithic library" FORCE)
add_subdirectory(submodules/USD)


