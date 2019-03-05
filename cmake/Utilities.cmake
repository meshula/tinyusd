
# Turn on folder usage
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

set(CMAKE_BUILD_TYPE Release)

# override cmake install prefix if it's not set,
# per: http://public.kitware.com/pipermail/cmake/2010-December/041135.html
IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    SET(CMAKE_INSTALL_PREFIX ${LOCAL_ROOT} CACHE PATH "Install set to local" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

function(lab_set_cxx_version proj vers)
    target_compile_features(${proj} INTERFACE cxx_std_${vers})
    set_property(TARGET ${proj} PROPERTY CXX_STANDARD ${vers})
    set_property(TARGET ${proj} PROPERTY CXX_STANDARD_REQUIRED ON)
endfunction()




#if (MSVC_VERSION GREATER_EQUAL "1900")
#    include(CheckCXXCompilerFlag)
#    CHECK_CXX_COMPILER_FLAG("/std:c++latest" _cpp_latest_flag_supported)
#    if (_cpp_latest_flag_supported)
#        add_compile_options("/std:c++latest")
#    endif()
#endif()




function(lab_default_definitions PROJ)

    if (WIN32)
        target_compile_definitions(${PROJ} PUBLIC PLATFORM_WINDOWS)

        target_compile_definitions(${PROJ} PUBLIC __TBB_NO_IMPLICIT_LINKAGE=1)
        target_compile_definitions(${PROJ} PUBLIC __TBBMALLOC_NO_IMPLICIT_LINKAGE=1)
        target_compile_definitions(${PROJ} PUBLIC NOMINMAX)
        target_compile_definitions(${PROJ} PUBLIC _CRT_SECURE_NO_WARNINGS)
        target_compile_definitions(${PROJ} PUBLIC _SCL_SECURE_NO_WARNINGS)
        target_compile_options(${PROJ} PRIVATE /arch:AVX /Zi )
#        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF" CACHE STRING "" FORCE)
        if (MSVC_IDE)
            # hack to get around the "Debug" and "Release" directories cmake tries to add on Windows
            #set_target_properties(LabRender PROPERTIES PREFIX "../")
            #set_target_properties(${PROJ} PROPERTIES IMPORT_PREFIX "../")
        endif()
    elseif (APPLE)
        target_compile_definitions(${PROJ} PUBLIC PLATFORM_DARWIN)
        target_compile_definitions(${PROJ} PUBLIC PLATFORM_MACOS)
    else()
        target_compile_definitions(${PROJ} PUBLIC PLATFORM_LINUX)
    endif()

    target_compile_definitions(${PROJ} PRIVATE 
        LABRENDER_BINDER_DLL
        LABRENDER_MODELLOADER_DLL)

    add_definitions(${_PXR_CXX_DEFINITIONS})
    set(CMAKE_CXX_FLAGS "${_PXR_CXX_FLAGS} ${CMAKE_CXX_FLAGS}")
endfunction()


