################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2022 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

project(stride_matrix
        DESCRIPTION "Stride Matrix"
        LANGUAGES CXX)

add_executable(${PROJECT_NAME})

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 23)

configure_target(${PROJECT_NAME}
                 PRIVATE_SOURCES
                   src/main.cpp
                 PRIVATE_DEPENDENCIES
        fmt::fmt
                   common)
