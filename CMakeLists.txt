
cmake_minimum_required(VERSION 3.11)
project(tinyusd)

set(TINYUSD_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
set(LOCAL_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/build/install")

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../LabCMake/scripts
                      ${CMAKE_CURRENT_SOURCE_DIR}/../LabCMake/modules)

set(LAB_PACKAGE_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/packages/vcpkg/installed/x64-windows)
set(LAB_BOOST_VCPKG ON)

include(Utilities)
include(Settings)
include(Packages)

add_executable(tinyusd "")
lab_default_definitions(tinyusd)
lab_set_cxx_version(tinyusd 14)

file(GLOB SRC "src/*.cpp")
file(GLOB HEADERS "headers/*.h")
target_sources(tinyusd PRIVATE ${SRC})
target_sources(tinyusd PRIVATE ${HEADERS})

target_compile_definitions(tinyusd PUBLIC ${USD_DEFINES})

target_include_directories(tinyusd PRIVATE
    ${tinyusd_ROOT}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/packages/vcpkg/installed/x64-windows/include
    ${LOCAL_ROOT}/include)

target_link_libraries(tinyusd ${USD_LIBRARIES})

if (MSVC_IDE)
    # hack to get around the "Debug" and "Release" directories cmake tries to add on Windows
    #set_target_properties(tinyusd PROPERTIES PREFIX "../")
    set_target_properties(tinyusd PROPERTIES IMPORT_PREFIX "../")
endif()

set_target_properties(tinyusd
    PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

install (TARGETS tinyusd
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin)

install (TARGETS tinyusd DESTINATION bin)

source_group(source FILES ${SRC})
source_group(headers FILES ${HEADERS})
