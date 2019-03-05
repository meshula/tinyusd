
cmake_minimum_required(VERSION 3.11)
project(tinyusd)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(Utilities)
find_package(Usd)
find_package(TBB)
find_package(Boost) # headers only

set(TINYUSD_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(tinyusd "")
lab_default_definitions(tinyusd)
lab_set_cxx_version(tinyusd 14)

file(GLOB SRC "src/*.cpp")
file(GLOB HEADERS "headers/*.h")
target_sources(tinyusd PRIVATE ${SRC})
target_sources(tinyusd PRIVATE ${HEADERS})

target_compile_definitions(tinyusd PUBLIC ${USD_DEFINES} PXR_STATIC)

target_include_directories(tinyusd PRIVATE
    ${USD_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
    ${tinyusd_ROOT}/src)

# note: target_link_libraries requires the optimized/debug keyword to be 
# applied per library, not to a list.
foreach(lib ${USD_LIBRARIES})
    target_link_libraries(tinyusd optimized ${lib})
endforeach()
foreach(lib ${USD_DEBUG_LIBRARIES})
    target_link_libraries(tinyusd debug ${lib})
endforeach()
target_link_libraries(tinyusd optimized ${TBB_tbb_LIBRARY_RELEASE} debug ${TBB_tbb_LIBRARY_DEBUG})

if (MSVC)
    target_link_libraries(tinyusd Shlwapi.lib Dbghelp.lib WSock32.lib)
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
