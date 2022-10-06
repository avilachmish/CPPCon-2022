################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2022 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

project(common
        DESCRIPTION "Common Library"
        LANGUAGES CXX)

add_library(${PROJECT_NAME} include/common/timedScope.hpp)
configure_target(${PROJECT_NAME}
                 NO_CLANG_TIDY
                 PUBLIC_SOURCES
                   include/common/timedScope.hpp
                   include/common/simplethreadpool.hpp
                 PRIVATE_SOURCES
                    src/simplethreadpool.cpp
        PRIVATE_DEPENDENCIES
        fmt::fmt
                   )
