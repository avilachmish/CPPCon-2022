################################################################################
##  Project ib_win_core                                                       ##
##  Copyright 2022 Incredibuild Software Ltd.                                 ##
##  All rights reserved                                                       ##
################################################################################

cmake_minimum_required(VERSION 3.21 FATAL_ERROR)

# @brief this script sets up project cmake build targets

# @brief configures a given target with common compilation and installation rules
# @param[in] TARGET_NAME name of the target to be configured
# @param[in][optional] NO_INSTALL do not add install rules for the given target
# @param[in][optional] PUBLIC_SOURCES list of target public include source files
# @param[in][optional] PRIVATE_SOURCES list of target private src source files
# @param[in][optional] RESOURCE_FILES list of target resource files to be copied to build folder and installed
# @param[in][optional] PUBLIC_DEPENDENCIES list of target public dependencies
# @param[in][optional] PRIVATE_DEPENDENCIES list of target private dependencies
function(configure_target TARGET_NAME)
  set(OPTIONS
      NO_INSTALL)
  set(ONE_VALUE_ARGS)
  set(MULTIVALUE_ARGS
        PUBLIC_SOURCES
        PRIVATE_SOURCES
        RESOURCE_FILES
        PUBLIC_DEPENDENCIES
        PRIVATE_DEPENDENCIES)
  cmake_parse_arguments(ADD_ARG "${OPTIONS}" "${ONE_VALUE_ARGS}" "${MULTIVALUE_ARGS}" ${ARGN})

  get_target_property(TARGET_TYPE_NAME ${TARGET_NAME} TYPE)
  set(TARGET_ACCESSOR "PUBLIC")

  if(TARGET_TYPE_NAME STREQUAL "INTERFACE_LIBRARY")
    set(TARGET_ACCESSOR "INTERFACE")

    if(ADD_ARG_PRIVATE_SOURCES)
      message(FATAL "INTERFACE target cannot have PRIVATE sources.")
    endif()

    if(ADD_ARG_PRIVATE_DEPENDENCIES)
      message(FATAL "INTERFACE target cannot have PRIVATE dependencies.")
    endif()
  endif()

  if(TARGET_TYPE_NAME STREQUAL "EXECUTABLE")
    if(ADD_ARG_PUBLIC_SOURCES)
      message(FATAL "EXECUTABLE target cannot have PUBLIC sources.")
    endif()

    if(ADD_ARG_PUBLIC_DEPENDENCIES)
      message(FATAL "EXECUTABLE target cannot have PUBLIC dependencies.")
    endif()
  endif()

  if(TARGET_TYPE_NAME STREQUAL "MODULE_LIBRARY")
    if(ADD_ARG_PUBLIC_SOURCES)
      message(FATAL "MODULE target cannot have PUBLIC sources.")
    endif()

    if(ADD_ARG_PUBLIC_DEPENDENCIES)
      message(FATAL "MODULE target cannot have PUBLIC dependencies.")
    endif()
  endif()

  if(PROJECT_DESCRIPTION STREQUAL CMAKE_PROJECT_DESCRIPTION)
    message(FATAL "Target project() DESCRIPTION field was not defined.")
  endif()

  if(ADD_ARG_ICON AND NOT TARGET_TYPE_NAME STREQUAL "EXECUTABLE")
    message(FATAL "ICON can only be set for a target of type EXECUTABLE")
  endif()

#  # generate export header for Windows DLL support
#  if(NOT TARGET_TYPE_NAME STREQUAL "EXECUTABLE" AND NOT TARGET_TYPE_NAME STREQUAL "INTERFACE_LIBRARY")
#    string(TOUPPER "${TARGET_NAME}" TARGET_NAME_UPPERCASE)
#    set(${TARGET_NAME}_EXPORT_FILE_NAME ${TARGET_NAME}_Export.hpp)
#    generate_export_header(${TARGET_NAME}
#                           BASE_NAME ${TARGET_NAME_UPPERCASE}
#                           EXPORT_MACRO_NAME ${TARGET_NAME_UPPERCASE}_EXPORT
#                           EXPORT_FILE_NAME ${${TARGET_NAME}_EXPORT_FILE_NAME}
#                           STATIC_DEFINE ${TARGET_NAME_UPPERCASE}_BUILT_AS_STATIC)
#
#    list(APPEND ADD_ARG_PUBLIC_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/${${TARGET_NAME}_EXPORT_FILE_NAME}")
#  endif()

  # target sources
  if(ADD_ARG_PUBLIC_SOURCES)
    target_sources(${TARGET_NAME} ${TARGET_ACCESSOR} ${ADD_ARG_PUBLIC_SOURCES})
    set_target_properties(${TARGET_NAME} PROPERTIES PUBLIC_HEADER "${ADD_ARG_PUBLIC_SOURCES}")

    target_include_directories(${TARGET_NAME}
                               ${TARGET_ACCESSOR}
                               "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include;${CMAKE_CURRENT_BINARY_DIR}>"
                               "$<INSTALL_INTERFACE:include>")
  endif()

  if(ADD_ARG_PRIVATE_SOURCES)
    target_sources(${TARGET_NAME} PRIVATE ${ADD_ARG_PRIVATE_SOURCES})

    target_include_directories(${TARGET_NAME}
                               PRIVATE
                               "${CMAKE_CURRENT_SOURCE_DIR}/src"
                               "${CMAKE_CURRENT_SOURCE_DIR}/src/${CMAKE_SYSTEM_NAME}")
  endif()

  # produce pdb on non release build types
  if(MSVC AND NOT TARGET_TYPE_NAME STREQUAL "INTERFACE_LIBRARY")
    target_compile_options(${TARGET_NAME} ${TARGET_ACCESSOR} "$<$<NOT:$<CONFIG:Debug>>:/Zi>")
    target_link_options(${TARGET_NAME} ${TARGET_ACCESSOR} "$<$<NOT:$<CONFIG:Debug>>:/DEBUG>")
    target_link_options(${TARGET_NAME} ${TARGET_ACCESSOR} "$<$<NOT:$<CONFIG:Debug>>:/OPT:REF>")
    target_link_options(${TARGET_NAME} ${TARGET_ACCESSOR} "$<$<NOT:$<CONFIG:Debug>>:/OPT:ICF>")
  endif()

  # target dependencies
  if(ADD_ARG_PUBLIC_DEPENDENCIES)
    target_link_libraries(${TARGET_NAME} ${TARGET_ACCESSOR} ${ADD_ARG_PUBLIC_DEPENDENCIES})
  endif()

  if(ADD_ARG_PRIVATE_DEPENDENCIES)
    target_link_libraries(${TARGET_NAME} PRIVATE ${ADD_ARG_PRIVATE_DEPENDENCIES})
  endif()

  # target resources
  if(ADD_ARG_RESOURCE_FILES)
    foreach(FILE ${ADD_ARG_RESOURCE_FILES})
      get_filename_component(DEPLOYED_FILE ${FILE} NAME)
      configure_file(${CMAKE_CURRENT_LIST_DIR}/${FILE} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${RESOURCES_DIRECTORY_NAME}/${DEPLOYED_FILE}
                     USE_SOURCE_PERMISSIONS
                     COPYONLY)
    endforeach()
  endif()

  # target installation
  if(NOT ADD_ARG_NO_INSTALL)
    set(COMPONENT_NAME "Applications")

    if(TARGET_TYPE_NAME STREQUAL "EXECUTABLE")
      install(TARGETS ${TARGET_NAME}
              EXPORT ${PROJECT_TARGETS_VAR_NAME}
              PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
              DESTINATION ${CMAKE_INSTALL_PREFIX} # RUNTIME is currently currently disabled until IB installation package is re-organized
              COMPONENT "${COMPONENT_NAME}")

      _install_target_pdb(${TARGET_NAME} ${COMPONENT_NAME} ${TARGET_TYPE_NAME})
    elseif(NOT TARGET_TYPE_NAME STREQUAL "STATIC_LIBRARY")
      set(COMPONENT_NAME "Libraries")

      install(TARGETS ${TARGET_NAME}
              PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
              DESTINATION ${CMAKE_INSTALL_PREFIX} # LIBRARY is currently currently disabled until IB installation package is re-organized
              COMPONENT "${COMPONENT_NAME}")

      _install_target_pdb(${TARGET_NAME} ${COMPONENT_NAME} ${TARGET_TYPE_NAME})
    endif()

    # install resources
    if(ADD_ARG_RESOURCE_FILES)
      install(FILES ${ADD_ARG_RESOURCE_FILES}
              DESTINATION ${CMAKE_INSTALL_PREFIX}/${RESOURCES_DIRECTORY_NAME} # TYPE BIN is currently disabled until IB installation package is re-organized
              PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
              COMPONENT "${COMPONENT_NAME}")
    endif()
  endif()
endfunction()

# @brief installs a given target generated pdb files
# @param[in] TARGET_NAME name of the target
# @param[in] COMPONENT_NAME name of the installation component
# @param[in] TARGET_TYPE_NAME name of the TARGET_NAME type
function(_install_target_pdb TARGET_NAME COMPONENT_NAME TARGET_TYPE_NAME)
  if(MSVC AND NOT TARGET_TYPE_NAME STREQUAL "INTERFACE_LIBRARY")
    # set the output name for debugger files, otherwise they are not generated
    set_target_properties(${TARGET_NAME}
                          PROPERTIES
                          COMPILE_PDB_NAME_DEBUG ${TARGET_NAME}
                          COMPILE_PDB_NAME_RELEASE ${TARGET_NAME}
                          COMPILE_PDB_NAME_MINSIZEREL ${TARGET_NAME}
                          COMPILE_PDB_NAME_RELWITHDEBINFO ${TARGET_NAME})

    install(FILES $<TARGET_PDB_FILE:${TARGET_NAME}>
            DESTINATION ${CMAKE_INSTALL_PREFIX} # BIN is currently currently disabled until IB installation package is re-organized
            COMPONENT "${COMPONENT_NAME}")
  endif()
endfunction()
