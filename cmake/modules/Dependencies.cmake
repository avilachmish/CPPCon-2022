################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief this script sets dependencies related configuration to the project

include(${CMAKE_CURRENT_LIST_DIR}/dependencies/packages/Packages.cmake)

# @brief setup installation definitions and variables
# @note: for this Exercise we won't restrict versions to dependencies.
macro(setup_dependencies_packages)
  message("")
  message("============ Dependencies ==============")

  list(APPEND DEPENDENCY_PACKAGES ${PACKAGES})
  list(APPEND DEPENDENCY_PACKAGES ${SYSTEM_PACKAGES})

  if(WITH_EXPERIMENTAL)
    list(APPEND DEPENDENCY_PACKAGES ${EXPERIMENTAL_PACKAGES})
    list(APPEND DEPENDENCY_PACKAGES ${EXPERIMENTAL_SYSTEM_PACKAGES})
  endif()

  foreach(PACKAGE ${DEPENDENCY_PACKAGES})
    string(REGEX REPLACE "/[^ ]*" "" PKG_NAME "${PACKAGE}")
    string(REGEX REPLACE ".*/" "" ${PKG_NAME}_VERSION "${PACKAGE}")

    if(EXISTS "${CMAKE_SOURCE_DIR}/cmake/modules/dependencies/setup_packages/Setup_${PKG_NAME}.cmake")
      include(Setup_${PKG_NAME})
    endif()
  endforeach()
endmacro()
