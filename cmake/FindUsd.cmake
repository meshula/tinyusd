
# author: Nick Porcino
# license: MIT

include_guard()

include(FindPackageHandleStandardArgs)

if(EXISTS "$ENV{USD_ROOT}")
    set(USD_ROOT $ENV{USD_ROOT})
endif()

find_package(Alembic)
find_package(Embree)
find_package(Houdini)
find_package(KatanaAPI)
find_package(Maya)

find_path(USD_INCLUDE_DIR pxr/pxr.h
    PATHS ${USD_LOCATION}
          ${USD_ROOT}
          /usr
          /usr/local
          /sw
          /opt/local

    PATH_SUFFIXES
        /include

    DOC "USD include directory")

if(WIN32)
    set(LIB_EXT "lib")
    set(DYLIB_EXT "dll")
elseif(APPLE)
    set(LIB_EXT "a")
    set(DYLIB_EXT "dylib")
else()
    set(LIB_EXT "a")
    set(DYLIB_EXT "so")
endif()

find_path(USD_LIBRARY_DIR 
    NAMES libusd.${LIB_EXT} usd_ms.${LIB_EXT}
    PATHS ${USD_INCLUDE_DIR}/../lib
    DOC "USD Libraries directory")

find_file(USD_GENSCHEMA
    names usdGenSchema
    PATHS ${USD_INCLUDE_DIR}/../bin
    DOC "USD Gen schema application")

# note that bin dir won't exist in the case that USD was built monolithically

find_path(USD_BIN_DIR usdview
    PATHS ${USD_INCLUDE_DIR}/../bin
    DOC "USD Bin directory")

if(Katana_FOUND)
    find_path(USD_KATANA_INCLUDE_DIR usdKatana/api.h
        PATHS ${USD_INCLUDE_DIR}/../third_party/katana/include ${KATANA_INCLUDE_DIR}
        DOC "USD Katana Include directory")

    find_path(USD_KATANA_LIBRARY_DIR libusdKatana.${DYLIB_EXT}
        PATHS ${USD_INCLUDE_DIR}/../third_party/katana/lib ${KATANA_LIBRARY_DIR}
        DOC "USD Katana Library directory")

    if(USD_KATANA_LIBRARY_DIR)
        mark_as_advanced(USD_KATANA_LIBRARY_DIR USD_KATANA_INCLUDE_DIR)
    endif()
endif()

if(Maya_FOUND)
    find_path(USD_MAYA_INCLUDE_DIR usdMaya/api.h
        PATHS ${USD_INCLUDE_DIR}/../third_party/maya/include ${MAYA_INCLUDE_DIR}
        DOC "USD Maya Include directory")

    find_path(USD_MAYA_LIBRARY_DIR libusdMaya.${DYLIB_EXT}
        PATHS ${USD_INCLUDE_DIR}/../third_party/maya/lib ${MAYA_LIBRARY_DIR}
        DOC "USD Maya Library directory")

    if(USD_MAYA_LIBRARY_DIR)
        mark_as_advanced(USD_MAYA_LIBRARY_DIR USD_MAYA_INCLUDE_DIR)
    endif()
endif()

if (Houdini_FOUND)
endif()

# prefer the monolithic static library, if it can be found
find_library(USD_MS_LIB_RELEASE usd_ms.${LIB_EXT}
    HINTS ${USD_LIBRARY_DIR} ${USD_INCLUDE_DIR}/..

    PATHS
        ${USD_LOCATION}
        ${USD_ROOT}
        /usr
        /usr/local
        /sw
        /opt/local

    PATH_SUFFIXES
        /lib

    DOC "USD library ${LIB}"
)

if (USD_MS_LIB_RELEASE)
    set(USD_LIB_NAMES usd_ms)
else()
    set(USD_LIB_NAMES
        ar arch gf js kind ndr pcp plug sdf sdr tf trace
        usd usdGeom usdHydra usdLux usdRi usdShade usdSkel usdUI
        usdUtils usdVol vt work
        )
endif()

if(Embree_FOUND)
    set(USD_LIB_NAMES ${USD_LIB_NAMES} hdEmbree)
endif()

if(Alembic_FOUND)
    set(USD_LIB_NAMES ${USD_LIB_NAMES} usdAbc)
endif()

foreach(_lib ${USD_LIB_NAMES})
    find_library(USD_${_lib}_LIB_RELEASE lib${_lib}
        HINTS ${USD_LIBRARY_DIR} ${USD_INCLUDE_DIR}/..

        PATHS
            ${USD_LOCATION}
            ${USD_ROOT}
            /usr
            /usr/local
            /sw
            /opt/local

        PATH_SUFFIXES
            /lib

        DOC "USD library ${LIB}"
    )

    if(USD_${_lib}_LIB_RELEASE)
        list(APPEND USD_LIBRARIES "${USD_${_lib}_LIB_RELEASE}")
        set(USD_${_lib}_FOUND TRUE)
        set(USD_${_lib}_LIBRARY "${USD_${_lib}_LIB_RELEASE}")
        list(APPEND USD_LIBRARIES "${USD_${_lib}_LIBRARY}")
        mark_as_advanced(USD_${_lib}_LIB_RELEASE)
    else()
        set(USD_${_lib}_FOUND FALSE)
    endif()

    find_library(USD_${_lib}_LIB_DEBUG lib${_lib}_d
        HINTS ${USD_LIBRARY_DIR} ${USD_INCLUDE_DIR}/..

        PATHS
            ${USD_LOCATION}
            ${USD_ROOT}
            /usr
            /usr/local
            /sw
            /opt/local

        PATH_SUFFIXES
            /lib

        DOC "USD library ${LIB}"
    )

    if(USD_${_lib}_LIB_DEBUG)
        list(APPEND USD_DEBUG_LIBRARIES "${USD_${_lib}_LIB_DEBUG}")
        set(USD_${_lib}_FOUND TRUE)
        set(USD_${_lib}_DEBUG_LIBRARY "${USD_${_lib}_LIB_DEBUG}")
        mark_as_advanced(USD_${_lib}_LIB_DEBUG)
    else()
        set(USD_${_lib}_DEBUG_FOUND FALSE)
    endif()

endforeach()

if (WIN32 OR APPLE)
    set(USD_DEFINES TF_NO_GNU_EXT)
endif()

find_package_handle_standard_args(USD
    REQUIRED_VARS
        USD_INCLUDE_DIR
        USD_LIBRARY_DIR
        USD_LIBRARIES
        USD_DEFINES)
