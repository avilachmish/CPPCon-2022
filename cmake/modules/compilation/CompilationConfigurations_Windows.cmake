################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief this script includes compilation configuration exclusive to Windows OS

# required for Windows generate_export_header.
# see @ https://cmake.org/cmake/help/latest/module/GenerateExportHeader.html
include(GenerateExportHeader)

# enable the ability to create folders to organize projects (.vcproj)
# It creates "CMakePredefinedTargets" folder by default and adds CMake
# defined projects like INSTALL.vcproj and ZERO_CHECK.vcproj
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# set path length check to Windows "long path".
# see more @ https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=registry
set(CMAKE_OBJECT_PATH_MAX 32767)

# enable exceptions
# see https://docs.microsoft.com/en-us/cpp/build/reference/eh-exception-handling-model?view=msvc-170
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")

# treat all compilation warnings as errors
# see more @ https://docs.microsoft.com/en-us/cpp/build/reference/compiler-option-warning-level?view=msvc-170
set(WARNINGS_AS_ERRORS_CXX_FLAG "/W4 /WX")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WARNINGS_AS_ERRORS_CXX_FLAG}")

# treat all linkage warnings as errors
set(WARNINGS_AS_ERRORS_LINKER_FLAG "/WX")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${WARNINGS_AS_ERRORS_LINKER_FLAG}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${WARNINGS_AS_ERRORS_LINKER_FLAG}")
set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} ${WARNINGS_AS_ERRORS_LINKER_FLAG}")

# ignore external libraries compilation warnings
# see more @ https://docs.microsoft.com/en-us/cpp/build/reference/external-external-headers-diagnostics?view=msvc-170
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /external:anglebrackets /external:W0")

# allow compilation of large object files
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")

# suppress msvc startup banner
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /nologo")
set(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} /nologo")

# resolves issues related to inclusion of "Windows.h"
# see more @ https://titanwolf.org/Network/Articles/Article?AID=3c00195a-a39e-4153-8365-7cea00bc3a80
add_definitions("-DWIN32_LEAN_AND_MEAN")

# set Windows SDK minimum required version
# see more @ https://docs.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt?view=msvc-170
add_definitions("-D_WIN32_WINNT=0x0603") # Windows 8.1

# set runtime library to the multithread, static version of the run-time library.
# @see https://docs.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library?view=msvc-170
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# due to a known bug in cmake-conan, CMAKE_MSVC_RUNTIME_LIBRARY fails to propagate to conan properly.
# @see https://github.com/conan-io/cmake-conan/issues/174
set(CMAKE_CXX_FLAGS_RELEASE "/MT ${CMAKE_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_DEBUG "/MTd ${CMAKE_CXX_FLAGS_DEBUG}")

# ignore missing 3rd party package pdb files which are not required
# @see https://docs.microsoft.com/en-us/cpp/error-messages/tool-errors/linker-tools-warning-lnk4099?view=msvc-170
set(IGNORE_MISSING_PDB_FLAG "/ignore:4099")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${IGNORE_MISSING_PDB_FLAG}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${IGNORE_MISSING_PDB_FLAG}")
set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} ${IGNORE_MISSING_PDB_FLAG}")

# compiler specific information
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  if(MSVC_CXX_ARCHITECTURE_ID MATCHES "64")
    set(SYSTEM_PROCESSOR "x86_64")
  elseif(MSVC_CXX_ARCHITECTURE_ID MATCHES "^ARM")
    set(SYSTEM_PROCESSOR "armv8")
  elseif(MSVC_CXX_ARCHITECTURE_ID MATCHES "86")
    set(SYSTEM_PROCESSOR "x86")
  endif()

  set(SYSTEM_PROCESSOR "${SYSTEM_PROCESSOR}")
  set(CXX_LIBRARY_ARCHITECTURE "${SYSTEM_PROCESSOR}")

  if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "AMD64")
    set(CMAKE_HOST_SYSTEM_PROCESSOR "x86_64")
  elseif(MSVC_CXX_ARCHITECTURE_ID MATCHES "^ARM")
    set(CMAKE_HOST_SYSTEM_PROCESSOR "armv8")
  elseif(MSVC_CXX_ARCHITECTURE_ID MATCHES "86")
    set(CMAKE_HOST_SYSTEM_PROCESSOR "x86")
  endif()
endif()

# workarounds for CMakePresets.json support in VS 2022. @see https://gitlab.kitware.com/cmake/cmake/-/issues/21616
if(VC_LIB)
  link_directories(${VC_LIB})
endif()

if(CMAKE_C_COMPILER)
  # do nothing
endif()

if(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES)
  # do nothing
endif()

if(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES)
  # do nothing
endif()
