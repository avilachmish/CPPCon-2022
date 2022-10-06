################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief This script will define helper functions related to Conan packages creation
#        and installation

# @brief downloads and includes Conan CMake wrapper
macro(initialize_conan)
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
    file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/release/0.18/conan.cmake"
         "${CMAKE_BINARY_DIR}/conan.cmake"
         TLS_VERIFY ON)
  endif()

  include(${CMAKE_BINARY_DIR}/conan.cmake)
endmacro()

# @brief creates a formatted list of "conan required" field with PACKAGES
# @param [in] PACKAGES list of conan packages to be required
# @param [in] OWNER name of "conan owner"
# @param [in] CHANNEL name of "conan channel"
# @param [out] REQUIRED_PKGS the formatted list of "conan required"
function(get_conan_required_pkgs PACKAGES OWNER CHANNEL REQUIRED_PKGS)
  set(REQUIRED_CONAN_PACKAGES "")

  foreach(PKG ${PACKAGES})
    list(APPEND REQUIRED_CONAN_PACKAGES "${PKG}@${CONAN_OWNER}/${CONAN_CHANNEL}")
  endforeach()

  set(${REQUIRED_PKGS} "${REQUIRED_CONAN_PACKAGES}" PARENT_SCOPE)
endfunction()

# @brief creates a formatted list of "conan package options"
# @param [in]  PACKAGES the list of conan packages to be built
# @param [out] PKGS_OPTIONS name of "conan owner"
function(get_conan_pkgs_options PACKAGES PKGS_OPTIONS)
  set(IS_SHARED_LIBRARY False)
  set(CONAN_PACKAGES_OPTIONS "")

  if(BUILD_SHARED_LIBS)
    set(IS_SHARED_LIBRARY True)
  endif()

  foreach(PKG ${PACKAGES})
    string(REGEX REPLACE "/[^ ]*" "" PKG_NAME "${PKG}")

    foreach(OPTION ${${PKG_NAME}_OPTIONS})
      list(APPEND CONAN_PACKAGES_OPTIONS
           "${PKG_NAME}:${OPTION}")
    endforeach()
  endforeach()

  set(${PKGS_OPTIONS} "${CONAN_PACKAGES_OPTIONS}" PARENT_SCOPE)
endfunction()

# @brief returns the settings variables for conan packages to be installed
# @param [in]  PACKAGES the list of conan packages to be built
# @param [out] CONAN_SETTINGS list of the settings variables for conan packages to be installed
function(get_conan_settings PACKAGES CONAN_SETTINGS)
  if(WIN32)
    conan_cmake_autodetect(SETTINGS)

    list(APPEND SETTINGS
         "os_build=${CMAKE_HOST_SYSTEM_NAME}"
         "arch_build=${CMAKE_HOST_SYSTEM_PROCESSOR}"
         "os=${CMAKE_SYSTEM_NAME}"
         "arch=${SYSTEM_PROCESSOR}")
    if(MSVC)
      list(APPEND SETTINGS
           "compiler.toolset=v${MSVC_TOOLSET_VERSION}")
    endif()
  else()
    set(SETTINGS
        "os_build=${CMAKE_HOST_SYSTEM_NAME}"
        "arch_build=${CMAKE_HOST_SYSTEM_PROCESSOR}"
        "os_target=${CMAKE_SYSTEM_NAME}"
        "arch_target=${SYSTEM_PROCESSOR}"
        "os=${CMAKE_SYSTEM_NAME}"
        "arch=${SYSTEM_PROCESSOR}")
  endif()

  # append package specific settings
  foreach(PKG ${PACKAGES})
    string(REGEX REPLACE "/[^ ]*" "" PKG_NAME "${PKG}")

    foreach(SETTING ${${PKG_NAME}_SETTINGS})
      list(APPEND SETTINGS
           "${PKG_NAME}:${SETTING}")
    endforeach()
  endforeach()

  set(${CONAN_SETTINGS} "${SETTINGS}" PARENT_SCOPE)
endfunction()

# @brief returns the environment variables for conan packages to be installed
# @param [out] ENVIRONMENT_ARGS list of the environment variables for conan packages to be installed
function(get_conan_environment_args ENVIRONMENT_ARGS)
  string(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPERCASE)
  get_filename_component(CMAKE_COMMAND_DIR "${CMAKE_COMMAND}" DIRECTORY)

  find_program(GIT_EXECUTABLE
               NAMES git
               REQUIRED
               DOC "git SCM client")

  string(REPLACE "${WARNINGS_AS_ERRORS_CXX_FLAG}" "" CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  string(REPLACE "${WARNINGS_AS_ERRORS_LINKER_FLAG}" "" LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")

  set(ENV_ARGS
      "PATH=[\"${CMAKE_COMMAND_DIR}\",\"${GIT_EXECUTABLE}\"]"
      "CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${BUILD_TYPE_UPPERCASE}}"
      "CXXFLAGS=${CXX_FLAGS} ${CMAKE_CXX_FLAGS_${BUILD_TYPE_UPPERCASE}}"
      "LINKER_FLAGS=${LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}}")

  if(UNIX)
    list(APPEND ENV_ARGS
         CC=${CMAKE_C_COMPILER}
         AS=${CMAKE_C_COMPILER}
         CXX=${CMAKE_CXX_COMPILER}
         AR=${CMAKE_AR}
         LD=${CMAKE_LINKER}
         NM=${CMAKE_NM}
         OBJCOPY=${CMAKE_OBJCOPY}
         OBJDUMP=${CMAKE_OBJDUMP}
         RANLIB=${CMAKE_RANLIB}
         STRIP=${CMAKE_STRIP}
         SYSROOT=${CMAKE_SYSROOT}
         TOOLCHAIN=${HOST_TOOLCHAIN_ROOT}
         CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
         TARGET=${CMAKE_LIBRARY_ARCHITECTURE})
  endif()

  set("${ENVIRONMENT_ARGS}" "${ENV_ARGS}" PARENT_SCOPE)
endfunction()

# @brief main function which invokes the setup of conan packages
macro(setup_conan)
  set(CONAN_OWNER "")
  set(CONAN_CHANNEL "")

  list(APPEND CONAN_PACKAGES ${PACKAGES})

  if(WITH_EXPERIMENTAL)
    list(APPEND CONAN_PACKAGES ${EXPERIMENTAL_PACKAGES})
  endif()

  build_conan_packages("${CONAN_PACKAGES}" "${CONAN_OWNER}" "${CONAN_CHANNEL}")
endmacro()

# @brief  invokes the build of conan packages
# @param [in] CONAN_PACKAGES the list of conan packages to be build
# @param [in] CONAN_OWNER name of "conan owner"
# @param [in] CONAN_CHANNEL name of "conan channel"
macro(build_conan_packages CONAN_PACKAGES CONAN_OWNER CONAN_CHANNEL)
  set(CONAN_REQUIRED_PKGS "")
  set(CONAN_PACKAGES_OPTIONS "")
  set(CONAN_SETTINGS "")
  set(CONAN_ENVIRONMENT_ARGS "")

  # @see https://docs.conan.io/en/latest/mastering/policies.html
  set(CONAN_BUILD_ARGS "cascade" "outdated")
  set(CONAN_UPDATE_ARG "UPDATE")
  set(CONAN_FILE "${CMAKE_CURRENT_BINARY_DIR}/conanfile.txt")

  message("")
  message("========== Conan Installation ==========")

  initialize_conan()

  get_conan_required_pkgs("${CONAN_PACKAGES}" "${CONAN_OWNER}" "${CONAN_CHANNEL}" CONAN_REQUIRED_PKGS)
  get_conan_pkgs_options("${CONAN_PACKAGES}" CONAN_PACKAGES_OPTIONS)
  get_conan_settings("${CONAN_PACKAGES}" CONAN_SETTINGS)
  get_conan_environment_args(CONAN_ENVIRONMENT_ARGS)

  set(GENERATOR_CONFIG_SUBDIR_NAME "")

  if("${CMAKE_GENERATOR}" MATCHES "Visual Studio")
    set(GENERATOR_CONFIG_SUBDIR_NAME "/${CMAKE_BUILD_TYPE}")
  endif()

  set(CONAN_CMAKE_CONFIG_PARAMS
      REQUIRES "${CONAN_REQUIRED_PKGS}"
      OPTIONS "${CONAN_PACKAGES_OPTIONS}"
      CONANFILE "${CONAN_FILE}"
      IMPORTS "bin, *.dll -> ./bin${GENERATOR_CONFIG_SUBDIR_NAME}"
      IMPORTS "bin, *.pdb -> ./bin${GENERATOR_CONFIG_SUBDIR_NAME}"
      IMPORTS "lib, * -> ./lib${GENERATOR_CONFIG_SUBDIR_NAME}"
      IMPORTS "libs, * -> ./lib${GENERATOR_CONFIG_SUBDIR_NAME}"
      BASIC_SETUP
      CMAKE_TARGETS
      KEEP_RPATHS
      NO_OUTPUT_DIRS
      GENERATORS
      cmake_paths
      cmake
      cmake_find_package
      cmake_multi)

  set(CONAN_CMAKE_INSTALL_PARAMS
      PATH_OR_REFERENCE .
#      REMOTE "ib-general-conan"
      BUILD "${CONAN_BUILD_ARGS}"
      SETTINGS "${CONAN_SETTINGS}"
      ENV "${CONAN_ENVIRONMENT_ARGS}"
      "${CONAN_UPDATE_ARG}")

  # setup for cmake build directory
  conan_cmake_configure(${CONAN_CMAKE_CONFIG_PARAMS})
  conan_cmake_install(${CONAN_CMAKE_INSTALL_PARAMS})

  # setup for cmake install directory
  install_conan_packages("${CONAN_PACKAGES}")

  # as of 2021-12-14 https://github.com/conan-io/cmake-conan version v0.16.1 there is an issue,
  # causing conan_paths.cmake not to be included, resulting in find_package failures
  include(${CMAKE_BINARY_DIR}/conan_paths.cmake)
endmacro()

# @brief declares installation paths of conan packages
# @param [in] PACKAGES the list of conan packages to be installed
function(install_conan_packages PACKAGES)
  include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)

  foreach(CONAN_PACKAGE ${PACKAGES})
    string(REGEX REPLACE "/[^ ]*" "" PACKAGE_NAME "${CONAN_PACKAGE}")
    string(TOUPPER "${PACKAGE_NAME}" PACKAGE_NAME)

    if(NOT "${CONAN_BIN_DIRS_${PACKAGE_NAME}}" STREQUAL "")
      file(GLOB CONAN_BINARIES "${CONAN_BIN_DIRS_${PACKAGE_NAME}}/*.dll")
      set(RUNTIME_OUTPUT_DIRECTORY_BINARIES)

      foreach(CONAN_BINARY ${CONAN_BINARIES})
        get_filename_component(CONAN_BINARY_NAME "${CONAN_BINARY}" NAME)
        list(APPEND RUNTIME_OUTPUT_DIRECTORY_BINARIES "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CONAN_BINARY_NAME}")
      endforeach()

      install(
        FILES ${RUNTIME_OUTPUT_DIRECTORY_BINARIES}
        DESTINATION ${CMAKE_INSTALL_PREFIX}) # TYPE LIB is currently disabled until IB installation package is re-organized
    endif()

    if(NOT "${CONAN_LIB_DIRS_${PACKAGE_NAME}}" STREQUAL "")
      install(
        DIRECTORY "${CONAN_LIB_DIRS_${PACKAGE_NAME}}/"
        DESTINATION ${CMAKE_INSTALL_PREFIX} # TYPE LIB is currently disabled until IB installation package is re-organized
        USE_SOURCE_PERMISSIONS
        FILES_MATCHING
        PATTERN "*.so")
    endif()
  endforeach()
endfunction()
