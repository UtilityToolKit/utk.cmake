#############################################################################
# Copyright 2018-2019 Utility Tool Kit Open Source Contributors             #
#                                                                           #
# Licensed under the Apache License, Version 2.0 (the "License");           #
# you may not use this file except in compliance with the License.          #
# You may obtain a copy of the License at                                   #
#                                                                           #
#     http://www.apache.org/licenses/LICENSE-2.0                            #
#                                                                           #
# Unless required by applicable law or agreed to in writing, software       #
# distributed under the License is distributed on an "AS IS" BASIS,         #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  #
# See the License for the specific language governing permissions and       #
# limitations under the License.                                            #
#############################################################################


cmake_minimum_required (VERSION 3.3)

if (NOT (CMAKE_VERSION VERSION_LESS 3.12))
  # The CMP0073 policy introduced in CMake 3.12 disables generation of <target
  # name>_LIB_DEPENDS variables when set to NEW. These variables are harmless
  # except for the INTERFACE_LIBRARY target case.
  cmake_policy (SET CMP0073 NEW)
endif ()

set (UTK_CMAKE_PACKAGE_MODULE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_PACKAGE_MODULE_DIRECTORY}/utk_cmake_list.cmake)
include (${UTK_CMAKE_PACKAGE_MODULE_DIRECTORY}/DownloadProject/DownloadProject.cmake)


# @function utk_cmake_find_or_download_package
#
# @brief Allows to use system-provided package or download package from remote
#        repository and build it as a part of the project.
#
# @details Package downloading is implemented with DownloadProject
#          (https://github.com/Innokentiy-Alaytsev/DownloadProject.git) CMake
#          module.
#
# @param [in] DOWNLOAD_AND_BUILD_BY_DEFAULT - when set the option
#                                             DOWNLOADANDBUILD_${PACKAGE} will
#                                             be set by default.
#
# @param [in] PACKAGE - the name of the package to find or download.
#
# @param [in] FOLDER - the name of the directory where the IMPORTED_TARGET will
#                      reside if USE_FOLDERS global property is set to TRUE.
#
# @param [in] FIND_PACKAGE_TARGET - the name of the IMPORTED target that will be
#                                   the result of the call to the find_package()
#                                   function; defaults to PACKAGE.
#
# @param [in] DOWNLOADED_TARGET - the name of the target that will be the result
#                                 of downloading the PACKAGE and adding it's
#                                 source directory into the project source tree;
#                                 defaults to PACKAGE.
#
# @param [in] IMPORTED_TARGET - the name of the variable in the PARENT SCOPE to
#                               store FIND_PACKAGE_TARGET or DOWNLOADED_TARGET
#                               value depending on whether the PACKAGE is found
#                               using the find_package() function or downloaded.
#
# @param [in] FIND_PACKAGE_OPTIONS - options to pass to the find_package()
#                                    function.
#
# @param [in] DOWNLOAD_OPTIONS - options to pass to the download_project()
#                                function.
#
# @param [in] DOWNLOAD_OPTIONS_WITH_OVERRIDE - a list of DOWNLOAD_OPTIONS that
#                                              may be overridden by the user; an
#                                              option
#                                              DOWNLOADANDBUILD_${PACKAGE}_<OPTION>
#                                              will be added.
function (utk_cmake_find_or_download_package)
  set (_options
    DOWNLOAD_AND_BUILD_BY_DEFAULT
    )
  set (_one_value_args
    PACKAGE
    FOLDER
    FIND_PACKAGE_TARGET
    DOWNLOADED_TARGET
    IMPORTED_TARGET
    )
  set (_multi_value_args
    FIND_PACKAGE_OPTIONS
    DOWNLOAD_OPTIONS
    DOWNLOAD_OPTIONS_WITH_OVERRIDE
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  option (DOWNLOADANDBUILD_${i_PACKAGE}
    "Download and build ${i_PACKAGE} (ON) or use system provided package (OFF)"
    ${i_DOWNLOAD_AND_BUILD_BY_DEFAULT}
    )

  if (NOT (CMAKE_VERSION VERSION_LESS 3.2))
    set (_force_update_docstring
      "Enforce update of the \"${i_PACKAGE}\" downloaded project during the next configuration (overrides DOWNLOADANDBUILD_${i_PACKAGE}_SKIP_UPDATE)")

    set (_skip_update_docstring
      "Skip update of the \"${i_PACKAGE}\" downloaded project during the configuration")

    option (DOWNLOADANDBUILD_${i_PACKAGE}_FORCE_UPDATE
      "${_force_update_docstring}"
      true
      )

    option (DOWNLOADANDBUILD_${i_PACKAGE}_SKIP_UPDATE
      "${_skip_update_docstring}"
      TRUE
      )
  endif()

  if (NOT DEFINED i_DOWNLOADED_TARGET)
    set (i_DOWNLOADED_TARGET ${i_PACKAGE})
  endif(NOT DEFINED i_DOWNLOADED_TARGET)

  if (NOT DEFINED i_FIND_PACKAGE_TARGET)
    set (i_FIND_PACKAGE_TARGET ${i_PACKAGE})
  endif(NOT DEFINED i_FIND_PACKAGE_TARGET)

  set (_imported_target "")

  if (DOWNLOADANDBUILD_${i_PACKAGE})
    set (_imported_target ${i_DOWNLOADED_TARGET})

    foreach (_overridable_option IN LISTS i_DOWNLOAD_OPTIONS_WITH_OVERRIDE)
      if ("${_overridable_option}" IN_LIST i_DOWNLOAD_OPTIONS)
        _utk_cmake_download_option_override (
          PACKAGE      "${i_PACKAGE}"
          OPTION_NAME  "${_overridable_option}"
          OPTION_LIST  ${i_DOWNLOAD_OPTIONS}
          OUTPUT       i_DOWNLOAD_OPTIONS
          )
      else ("${_overridable_option}" IN_LIST i_DOWNLOAD_OPTIONS)
        message (
          SEND_ERROR
          "Impossible to override download option \"${_overridable_option}\" that is not provided")
      endif ("${_overridable_option}" IN_LIST i_DOWNLOAD_OPTIONS)
    endforeach (_overridable_option IN LISTS i_DOWNLOAD_OPTIONS_WITH_OVERRIDE)

    # Package info variables
    string (MAKE_C_IDENTIFIER
      "utk_cmake_find_or_download_package_${i_PACKAGE}_${i_DOWNLOAD_OPTIONS}"
      _package_info_var_id)

    string (MD5
      _package_id
      "${i_DOWNLOAD_OPTIONS}"
      )

    set (_package_prefix  "${CMAKE_BINARY_DIR}/${i_PACKAGE}/${_package_id}")

    if (NOT TARGET "${i_DOWNLOADED_TARGET}")
      if (CMAKE_VERSION VERSION_LESS 3.2)
        set (UPDATE_DISCONNECTED_IF_AVAILABLE "")

        set (_skip_update FALSE)
      else()
        if (${DOWNLOADANDBUILD_${i_PACKAGE}_FORCE_UPDATE})
          set (
            DOWNLOADANDBUILD_${i_PACKAGE}_FORCE_UPDATE false
            CACHE BOOL "${_force_update_docstring}" FORCE)

          set (_skip_update FALSE)
        else ()
          set (UPDATE_DISCONNECTED_IF_AVAILABLE "UPDATE_DISCONNECTED 1")

          if ((${_package_info_var_id}_SOURCE_DIR AND
                EXISTS "${${_package_info_var_id}_SOURCE_DIR}") AND
              (${_package_info_var_id}_BINARY_DIR AND
                EXISTS "${${_package_info_var_id}_BINARY_DIR}"))
            set (_skip_update  ${DOWNLOADANDBUILD_${i_PACKAGE}_SKIP_UPDATE})
          else ()
            set (_skip_update  FALSE)
          endif ()
        endif ()
      endif()

      if (NOT _skip_update)
        download_project (
          PROJ                ${i_PACKAGE}
          PREFIX              ${_package_prefix}
          ${i_DOWNLOAD_OPTIONS}
          ${UPDATE_DISCONNECTED_IF_AVAILABLE}
          )

        set (${_package_info_var_id}_SOURCE_DIR  "${${i_PACKAGE}_SOURCE_DIR}"
          CACHE  INTERNAL  "" FORCE
          )
        set (${_package_info_var_id}_BINARY_DIR  "${${i_PACKAGE}_BINARY_DIR}"
          CACHE  INTERNAL  "" FORCE
          )
      endif ()

      add_subdirectory (
        ${${_package_info_var_id}_SOURCE_DIR}
        ${${_package_info_var_id}_BINARY_DIR})
    endif ()
  else ()
    find_package (${i_PACKAGE} ${i_FIND_PACKAGE_OPTIONS})

    set (_imported_target ${i_FIND_PACKAGE_TARGET})
  endif ()

  get_target_property (_imported_target_type  "${_imported_target}"  TYPE)

  if (i_FOLDER AND
      NOT (_imported_target_type STREQUAL "INTERFACE_LIBRARY"))
    set_target_properties (
      ${_imported_target}
      PROPERTIES
      FOLDER  "${i_FOLDER}"
      )
  endif ()

  if (_imported_target_type STREQUAL "INTERFACE_LIBRARY")
    # A workaround for deprecated variables that are generated for the
    # downloaded INTERFACE_LIBRARY targets while they are not needed
    # (https://gitlab.kitware.com/cmake/cmake/issues/16364).
    unset ("${i_PACKAGE}_LIB_DEPENDS"  CACHE)
    unset ("${_imported_target}_LIB_DEPENDS"  CACHE)
  endif ()

  set (${i_IMPORTED_TARGET} ${_imported_target} PARENT_SCOPE)
endfunction (utk_cmake_find_or_download_package)


# @function utk_cmake_download_and_use_googletest
#
# @brief Convinience function for downloading Google Test framework
#
# @details Downloads the Google Test framework by default, sets it up to build
#          as a static library, sets up warning options when needed and resets
#          INSTALL_* options for Google Test and Google Mock.
#
# @param [in] OUTPUT_ADDITIONAL_TARGET_PROPERTIES - the name of the variable in
#             the parent scope to store additional properties which include
#             target link libraries to use Google test framework to build the
#             targets that use it.
function (utk_cmake_download_and_use_googletest)
  set (_options
    ""
    )
  set (_one_value_args
    OUTPUT_ADDITIONAL_TARGET_PROPERTIES
    )
  set (_multi_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  set (OLD_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
  set (OLD_BUILD_STATIC_LIBS ${BUILD_STATIC_LIBS})

  # Google Test should be built in static library to prevent linking problems
  set (BUILD_SHARED_LIBS OFF)
  set (BUILD_STATIC_LIBS ON)

  utk_cmake_find_or_download_package (
    PACKAGE               googletest
    DOWNLOAD_AND_BUILD_BY_DEFAULT
    DOWNLOADED_TARGET     "gtest"
    IMPORTED_TARGET       googletest_target
    FIND_PACKAGE_TARGET   "gtest"
    FIND_PACKAGE_OPTIONS  ""
    DOWNLOAD_OPTIONS
    GIT_TAG               origin/master
    GIT_REPOSITORY        https://github.com/google/googletest.git
    DOWNLOAD_OPTIONS_WITH_OVERRIDE
    GIT_TAG
    GIT_REPOSITORY
    )

  set (_targets_to_set_properties
    gmock
    gmock_main
    gtest
    gtest_main
    )

  # Building with CLang on MSVS 2017 gives a lot of warnings for deprecated and
  # non-portable functions. Disable those warnings with the preprocessor
  # definitions.
  set (_additional_target_properties
    "COMPILE_DEFINITIONS\;_CRT_SECURE_NO_WARNINGS\\\;_CRT_NONSTDC_NO_WARNINGS"
    )

  # Building with CLang may result in warnings about unused command line
  # options. Disable this kind of warnings with -Qunused-arguments command line
  # option.
  if (MSVC AND ("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xClang"))
    set (_additional_target_properties
      "${_additional_target_properties};COMPILE_OPTIONS\;-Qunused-arguments")
  endif ()

  foreach (_target IN LISTS _targets_to_set_properties)
    if (TARGET ${_target})
      if (PROJECT_FOLDER)
        set_property (
          TARGET ${_target}
          PROPERTY FOLDER
          "${PROJECT_FOLDER}/Tests/Google Test"
          )
      endif ()

      foreach (_additional_property IN LISTS _additional_target_properties)
        set_property (
          TARGET ${_target}
          APPEND PROPERTY
          ${_additional_property}
          )
      endforeach ()
    endif ()
  endforeach ()

  # Prevent GoogleTest from overriding our compiler/linker options
  # when building with Visual Studio.
  set (gtest_force_shared_crt ON CACHE BOOL "" FORCE)

  # Disable GoogleTest installation by default.
  set (INSTALL_GMOCK OFF CACHE BOOL "" FORCE)
  set (INSTALL_GTEST OFF CACHE BOOL "" FORCE)

  # Restore BUILD_SHARED_LIBS and BUILD_STATIC_LIBS. Maybe not needed, but this
  # way it is a bit safer.
  set (BUILD_SHARED_LIBS ${OLD_BUILD_SHARED_LIBS})
  set (BUILD_STATIC_LIBS ${OLD_BUILD_STATIC_LIBS})

  # Return additional target properties that are required to use Google Test.
  if (i_OUTPUT_ADDITIONAL_TARGET_PROPERTIES)
    set (
      ${i_OUTPUT_ADDITIONAL_TARGET_PROPERTIES}
      "${_additional_target_properties}" PARENT_SCOPE)
  endif ()
endfunction (utk_cmake_download_and_use_googletest)



######################
# Internal functions #
######################
function (_utk_cmake_download_option_override)
  set (_multi_value_args
    OPTION_LIST
    )
  set (_one_value_args
    PACKAGE
    OPTION_NAME
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  option (DOWNLOADANDBUILD_${i_PACKAGE}_OVERRIDE_${i_OPTION_NAME}
    "Enables override of the \"${i_OPTION_NAME}\" option used to fetch package sources with ExternalProject"
    OFF
    )

  if (DOWNLOADANDBUILD_${i_PACKAGE}_OVERRIDE_${i_OPTION_NAME})
    utk_cmake_get_named_option (
      OPTION_LIST ${i_OPTION_LIST}
      OPTION_NAME "${i_OPTION_NAME}"
      OUTPUT _option_value)

    set (DOWNLOADANDBUILD_${i_PACKAGE}_ALTERNATIVE_${i_OPTION_NAME}
      "${_option_value}"
      CACHE
      STRING
      "\"${i_OPTION_NAME}\" used to override the one provided in project configuration"
      )

    utk_cmake_set_named_option (
      OPTION_LIST ${i_OPTION_LIST}
      OPTION_NAME "${i_OPTION_NAME}"
      OPTION_VALUE "${DOWNLOADANDBUILD_${i_PACKAGE}_ALTERNATIVE_${i_OPTION_NAME}}"
      OUTPUT _option_list)

    set (${i_OUTPUT} ${_option_list} PARENT_SCOPE)
  endif(DOWNLOADANDBUILD_${i_PACKAGE}_OVERRIDE_${i_OPTION_NAME})
endfunction (_utk_cmake_download_option_override)
