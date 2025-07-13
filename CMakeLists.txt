cmake_minimum_required(VERSION 3.11)
project(tinyusd)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(Utilities)

# Find packages with proper error handling
find_package(pxr REQUIRED)
find_package(TBB REQUIRED)
find_package(OpenGL REQUIRED) # for garch

set(TINYUSD_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "TinyUSD root is ${TINYUSD_ROOT}")

add_executable(tinyusd "")
lab_default_definitions(tinyusd)
lab_set_cxx_version(tinyusd 17)

# Source files
file(GLOB SRC "src/*.cpp")
file(GLOB HEADERS "include/*.h")
target_sources(tinyusd PRIVATE ${SRC} ${HEADERS})

# Compiler definitions
target_compile_definitions(tinyusd PUBLIC ${USD_DEFINES})

# Include directories
target_include_directories(tinyusd PRIVATE
    ${PXR_INCLUDE_DIR}
    ${TINYUSD_ROOT}/include
    ${TINYUSD_ROOT}/src)

# Link libraries - conditional approach for static vs dynamic
if(BUILD_SHARED_LIBS)
    # Dynamic linking - use full library set
    target_link_libraries(tinyusd PRIVATE
        ${PXR_LIBRARIES}
        TBB::tbb
    )
else()
    # Static linking - sanity check: test ONLY gf (no tf)
    target_link_libraries(tinyusd PRIVATE
        arch
        gf
        TBB::tbb
    )
endif()

message(STATUS "PXR_LIBRARIES contains: ${PXR_LIBRARIES}")
string(REPLACE ";" "|" PXR_LIBRARIES_DEBUG "${PXR_LIBRARIES}")
message(STATUS "PXR_LIBRARIES debug: ${PXR_LIBRARIES_DEBUG}")

# Platform-specific libraries
if (MSVC)
    target_link_libraries(tinyusd PRIVATE Shlwapi.lib Dbghelp.lib WSock32.lib)
endif()

# Output directories
set_target_properties(tinyusd
    PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Installation
install(TARGETS tinyusd
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin)

install(TARGETS tinyusd DESTINATION bin)

# Source groups for IDE
source_group(source FILES ${SRC})
source_group(headers FILES ${HEADERS})