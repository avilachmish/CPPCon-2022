################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief this script sets compilation related configuration to the project

# @brief setup compilation definitions and flags
macro(setup_compilation_configuration)
  # check if OS type is Linux
  if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(LINUX 1)
  endif()

  # enable exporting of compile commands. @see https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
  set(CMAKE_EXPORT_COMPILE_COMMANDS True)

  ## C++ Compilation
  set(SYSTEM_PROCESSOR "${CMAKE_SYSTEM_PROCESSOR}")
  set(CXX_LIBRARY_ARCHITECTURE "${CMAKE_CXX_LIBRARY_ARCHITECTURE}")

  include(${CMAKE_SOURCE_DIR}/cmake/modules/compilation/CompilationConfigurations_${CMAKE_SYSTEM_NAME}.cmake)

  if(STRICT_BUILD_FLAGS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${STRICT_BUILD_FLAGS}")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${STRICT_BUILD_FLAGS}")
  endif()

  ## Boost Compilation
  add_definitions("-DBOOST_SYSTEM_NO_DEPRECATED")
  add_definitions("-DBOOST_FILESYSTEM_NO_DEPRECATED")
  add_definitions("-DBOOST_ASIO_ENABLE_CANCELIO")

  # workaround for clang 14 issue with C++20.
  # @see https://stackoverflow.com/questions/61571913/c20-asioco-spawn-constraints-are-not-statisfied
  #      https://github.com/chriskohlhoff/asio/issues/859
  add_definitions("-DBOOST_ASIO_HAS_STD_COROUTINE")
  add_definitions("-DBOOST_ASIO_HAS_CO_AWAIT")
endmacro()
