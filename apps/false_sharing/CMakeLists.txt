################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2022 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

project(false_sharing
        DESCRIPTION "False Sharing"
        LANGUAGES CXX)

add_executable(${PROJECT_NAME})

configure_target(${PROJECT_NAME}
        PRIVATE_SOURCES
        src/main.cpp
        PRIVATE_DEPENDENCIES
        common
        Threads::Threads
        fmt::fmt)
