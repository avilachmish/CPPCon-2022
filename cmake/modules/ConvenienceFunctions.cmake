################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2021 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# Various CMake convenience functions and macros

# @brief prints cmake rest_service information
function(print_cmake_configuration_summary)
  get_directory_property(CURRENT_COMPILE_DEFINITIONS COMPILE_DEFINITIONS)
  string(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPERCASE)

  message("")
  message("========= Build Configuration ==========")
  message(STATUS "Build Time (UTC):                       ${BUILD_YEAR}-${BUILD_MONTH}-${BUILD_DAY}")
  message(STATUS "Project Version:                        ${CMAKE_PROJECT_VERSION}")
  message(STATUS "Build Type:                             ${CMAKE_BUILD_TYPE}")
  message("")
  message(STATUS "BUILD_NUMBER:                           ${BUILD_NUMBER}")
  message(STATUS "BUILD_SHARED_LIBS:                      ${BUILD_SHARED_LIBS}")
  message(STATUS "WITH_EXPERIMENTAL:                      ${WITH_EXPERIMENTAL}")
  message(STATUS "WITH_TESTING:                           ${WITH_TESTING}")
  message(STATUS "WITH_COVERAGE:                          ${WITH_COVERAGE}")
  message(STATUS "WITH_LOGGING:                           ${WITH_LOGGING}")
  message(STATUS "WITH_SIGNING:                           ${WITH_SIGNING}")
  message(STATUS "WITH_CLANG_TIDY:                        ${WITH_CLANG_TIDY}")
  message(STATUS "WITH_ADDRESS_SANITIZER:                 ${WITH_ADDRESS_SANITIZER}")
  message(STATUS "AUTOGEN_IN_SOURCE:                      ${AUTOGEN_IN_SOURCE}")

  message("")
  message("========== Host Configuration ==========")
  message(STATUS "System:                                 ${CMAKE_HOST_SYSTEM_NAME}")
  message(STATUS "Processor:                              ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  message(STATUS "Version:                                ${CMAKE_HOST_SYSTEM_VERSION}")

  message("")
  message("========= Target Configuration =========")
  message(STATUS "System:                                 ${CMAKE_SYSTEM_NAME}")
  message(STATUS "Processor:                              ${SYSTEM_PROCESSOR}")
  message(STATUS "Version:                                ${CMAKE_SYSTEM_VERSION}")
  message(STATUS "Architecture:                           ${CXX_LIBRARY_ARCHITECTURE}")
  message(STATUS "MSVC Version:                           ${MSVC_VERSION}")
  message(STATUS "MSVC Runtime Library:                   ${CMAKE_MSVC_RUNTIME_LIBRARY}")
  message(STATUS "MSVC Toolset Version:                   ${MSVC_TOOLSET_VERSION}")
  message(STATUS ".NET Framework Version:                 ${CMAKE_DOTNET_TARGET_FRAMEWORK_VERSION}")
  message(STATUS "Compile Definitions:                    ${CURRENT_COMPILE_DEFINITIONS}")
  message(STATUS "CXX Flags:                              CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")
  message(STATUS "Build Type CXX Flags:                   CMAKE_CXX_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_CXX_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "Executable Linker Flags:                CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}")
  message(STATUS "Build Type Executable Linker Flags:     CMAKE_EXE_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_EXE_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "Shared Library Linker Flags:            CMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}")
  message(STATUS "Build Type Shared Library Linker Flags: CMAKE_SHARED_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_SHARED_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "Static Library Linker Flags:            CMAKE_STATIC_LINKER_FLAGS=${CMAKE_STATIC_LINKER_FLAGS}")
  message(STATUS "Build Type Static Library Linker Flags: CMAKE_STATIC_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_STATIC_LINKER_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "Delphi5 Flags:                          CMAKE_Delphi5_FLAGS=${CMAKE_Delphi5_FLAGS}")
  message(STATUS "Build Type Delphi5 Flags:               CMAKE_Delphi5_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_Delphi5_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "FreePascal Flags:                       CMAKE_FreePascal_FLAGS=${CMAKE_FreePascal_FLAGS}")
  message(STATUS "Build Type FreePascal Flags:            CMAKE_FreePascal_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_FreePascal_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "Delphi2007 Flags:                       CMAKE_Delphi2007_FLAGS=${CMAKE_Delphi2007_FLAGS}")
  message(STATUS "Build Type Delphi2007 Flags:            CMAKE_Delphi2007_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_Delphi2007_FLAGS_${BUILD_TYPE_UPPERCASE}}")
  message(STATUS "DelphiXE3 Flags:                        CMAKE_DelphiXE3_FLAGS=${CMAKE_DelphiXE3_FLAGS}")
  message(STATUS "Build Type DelphiXE3 Flags:             CMAKE_DelphiXE3_FLAGS_${BUILD_TYPE_UPPERCASE}=${CMAKE_DelphiXE3_FLAGS_${BUILD_TYPE_UPPERCASE}}")

  message("")
  message("====== Installation Configuration ======")
  message(STATUS "Installation Path:                      ${CMAKE_INSTALL_PREFIX}")
endfunction()

# @brief sets CMAKE_BUILD_TYPE to a default value, in case user did not specify explicitly a build type
# @note it seems that on UNIX systems, CMake sets CMAKE_BUILD_TYPE as "Release" by default, while on
#       Windows it does not
function(setup_default_cmake_build_type)
  set(DEFAULT_BUILD_TYPE "Release")

  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "${DEFAULT_BUILD_TYPE}" CACHE STRING "Build project with specified build type" FORCE)

    # sets possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
  endif()
endfunction()

# @brief returns state flags according to BUILD_SHARED_LIBS
# @param [out] IS_SHARED_LIB True if BUILD_SHARED_LIBS is True, else False
# @param [out] IS_STATIC_LIB False if BUILD_SHARED_LIBS is True, else True
function(get_shared_target_states IS_SHARED_LIB IS_STATIC_LIB)
  if(BUILD_SHARED_LIBS)
    set(IS_SHARED "True")
    set(IS_STATIC "False")
  else()
    set(IS_SHARED "False")
    set(IS_STATIC "True")
  endif()

  set(${IS_SHARED_LIB} "${IS_SHARED}" PARENT_SCOPE)
  set(${IS_STATIC_LIB} "${IS_STATIC}" PARENT_SCOPE)
endfunction()

# @brief adds 0s add the beginning of a given number
# @param[in] NUM number to be padded with 0s prefixed
# @param[in] NUM_OF_DIGITS number of digits of the output PADDED_NUM
# @param[out] PADDED_NUM NUM with prefixed 0s of size NUM_OF_DIGITS
function(pad_number_with_zero NUM NUM_OF_DIGITS PADDED_NUM)
  string(LENGTH "${NUM}" NUM_LENGTH)
  math(EXPR PADDING_LENGTH "${NUM_OF_DIGITS} - ${NUM_LENGTH}")

  if(${PADDING_LENGTH} GREATER 0)
    foreach(INDEX RANGE 1 ${PADDING_LENGTH})
      set(NUM "0${NUM}")
    endforeach()
  endif()

  set(${PADDED_NUM} "${NUM}" PARENT_SCOPE)
endfunction()

# @brief checks if a given target is implemented in Delphi
# @param[in] TARGET_NAME name of the target to be checked
# @param[out] IS_DELPHI_TARGET true if target is implemented in Delphi, else false
function(is_delphi_target TARGET_NAME IS_DELPHI_TARGET)
  get_target_property(TARGET_SOURCES ${TARGET_NAME} SOURCES)

  foreach(TARGET_SOURCE ${TARGET_SOURCES})
    set(RESULT False)
    string(FIND "${TARGET_SOURCE}" ".dpr" INDEX REVERSE)

    if(INDEX GREATER -1)
      set(RESULT True)
      break()
    endif()
  endforeach()

  set(${IS_DELPHI_TARGET} ${RESULT} PARENT_SCOPE)
endfunction()

# @brief check if project build type is "Release"
# @param[out] IS_RELEASE_BUILD true if project build type is of "Release", else false
function(is_relase_build_type IS_RELEASE_BUILD)
  set(IS_RELEASE False)
  string(TOUPPER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_UPPERCASE)

  if("${BUILD_TYPE_UPPERCASE}" STREQUAL "RELEASE")
    set(IS_RELEASE True)
  endif()

  set(${IS_RELEASE_BUILD} "${IS_RELEASE}" PARENT_SCOPE)
endfunction()

# @brief removes last char from a given string
# @param [in] INPUT_STRING the given string to be modified
# @param [out] OUTPUT_STRING INPUT_STRING without the last char
function(remove_last_char_from_string INPUT_STRING OUTPUT_STRING)
    string(LENGTH "${INPUT_STRING}" STR_LENGTH)

    if(STR_LENGTH GREATER 0)
        math(EXPR NEW_LENGTH "${STR_LENGTH} - 1")
        string(SUBSTRING "${INPUT_STRING}" 0 ${NEW_LENGTH} INPUT_STRING)
    endif()

    set(${OUTPUT_STRING} "${INPUT_STRING}" PARENT_SCOPE)
endfunction()
