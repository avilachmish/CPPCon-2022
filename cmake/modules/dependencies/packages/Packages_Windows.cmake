################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief This script will define Windows specific required project packages

# @brief add to list of required project packages
list(APPEND PACKAGES)

list(APPEND EXPERIMENTAL_PACKAGES)

list(APPEND SYSTEM_PACKAGES
     rc)

## Packages Conan Options

