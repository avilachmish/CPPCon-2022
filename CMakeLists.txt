
cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

## Include Modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/dependencies/find_modules")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/dependencies/setup_packages")

## Project
message("")
message("============ CPPCON 2022 ============")

project(cppcon_2022
        VERSION 1.0.0
        DESCRIPTION "cppcon_2022"
#        HOMEPAGE_URL "https://bitbucket.org/IncredibuildRND/ib_win_core.git"
        LANGUAGES CXX)

# C++ global standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)


set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-z,stack-size=1600000000")
#set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /STACK:160000000")
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

## Options
option(BUILD_SHARED_LIBS "Build using shared libraries" False)

## Setup
include(cmake/modules/Compilation.cmake)
include(cmake/modules/Conan.cmake)
include(cmake/modules/ConvenienceFunctions.cmake)
include(cmake/modules/Dependencies.cmake)
include(cmake/modules/Installation.cmake)
include(cmake/modules/Target.cmake)

setup_default_cmake_build_type()

setup_compilation_configuration()
setup_installation_configuration()

print_cmake_configuration_summary()

setup_conan()
setup_dependencies_packages()

## Targets
# apps
add_subdirectory(apps/false_sharing)
add_subdirectory(apps/matrix)
add_subdirectory(apps/stride_matrix)
add_subdirectory(apps/conflict_miss)

# libs
add_subdirectory(libs/common)

message("")
message("=============================================")
