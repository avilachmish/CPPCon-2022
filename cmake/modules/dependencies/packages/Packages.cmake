################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief This script will define the required project packages

# @brief list of required project packages
set(PACKAGES
    bzip2/1.0.8
    zlib/1.2.12
    boost/1.79.0 # must come after bzip2 and zlib
    fmt/9.0.0)

# @brief list of required packages on host system
set(SYSTEM_PACKAGES)

# @brief list of required project packages for targets build WITH_EXPERIMENTAL
set(EXPERIMENTAL_PACKAGES)

# @brief list of required packages on host system  for targets build WITH_EXPERIMENTAL
set(EXPERIMENTAL_SYSTEM_PACKAGES)

## Packages Conan Options
get_shared_target_states(IS_SHARED_LIB IS_STATIC_LIB)

set(boost_OPTIONS
    shared=${IS_SHARED_LIB})

set(fmt_OPTIONS
    shared=${IS_SHARED_LIB})

include(${CMAKE_CURRENT_LIST_DIR}/Packages_${CMAKE_SYSTEM_NAME}.cmake)
