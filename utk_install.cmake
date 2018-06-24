#############################################################################
# Copyright 2018 Utility Tool Kit Open Source Contributors (see CREDITS.md) #
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


include(CMakePackageConfigHelpers)

set (UTK_CMAKE_INSTALL_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_INSTALL_MODULE_DIR}/utk_cmake_utils.cmake)


# @function utk_cmake_install_project
#
# @brief Adds install target to install libraries, executables and other files,
#        associated with the given target(s)
#
# @details Target files installation is implemented using the
#          $<BUILD_INTERFACE:...> and $<INSTALL_INTERFACE:...> generator
#          expressions. These expressions must be used with the target_sources()
#          function to add target sources (and other files) intended for
#          installation. $<INSTALL_INTERFACE:...> should specify the correct
#          file path relative to the installation prefix.
#
# @param [in] CREATE_PRODUCT_INFO_FUNCTIONS - if set then product information
#                                             functions will be generated.
#
# @param [in] TARGET - a target name or a list of targets to process.
#
# @param [in] COMMON_TARGET_IDENTIFIER - common identifier for all targets being
#                                        processed.
#
# @param [in] ICON - icon file name.
#
# @param [in] USE_ICON - if set then the icon will be embedded into the target's
#                        resources (Win32 only).
#
# @param [in] CONTRIBUTORS_FILE - name of the file with the project contributors
#                                 list; if provided then the corresponding
#                                 information function will be generated.
#
# @param [in] LICENSE_FILE - name of the file with the project license; if
#                            provided then the corresponding information
#                            function will be generated.
#
# @param [in] NOTICE - name of the file with the project notice; if provided
#                      then the corresponding information function will be
#                      generated.
#
# @param [in] BUNDLE_(FILE|STRING) - a string or a name of the file with a
#                                    string representing product bundle name
#                                    (Win32 only).
#
# @param [in] COMMENTS_(FILE|STRING) - a string or a name of the file with a
#                                      string representing product bundle name
#                                      (Win32 only).
#
# @param [in] COPYRIGHT_INFO_(FILE|STRING) - a string or a name of the file with
#                                            a string representing product
#                                            bundle name (Win32 only).
#
# @param [in] COPYRIGHT_INFO_UTF8_(FILE|STRING) - a string or a name of the file
#                                                 with a string representing
#                                                 product bundle name.
#
# @param [in] FILE_DESCRIPTION_(FILE|STRING) - a string or a name of the file
#                                              with a string representing
#                                              product bundle name (Win32
#                                              only).
#
# @param [in] INTERNAL_NAME_(FILE|STRING) - a string or a name of the file with
#                                           a string representing product bundle
#                                           name (Win32 only).
#
# @param [in] LICENSE_NAME_(FILE|STRING) - a string or a name of the file with a
#                                          string representing product bundle
#                                          name; required if LICENSE_FILE is
#                                          provided.
#
# @param [in] ORIGINAL_FILENAME_(FILE|STRING) - a string or a name of the file
#                                               with a string representing
#                                               product bundle name (Win32
#                                               only).
function (utk_cmake_install_project)
  set (_options
    ""
    )
  set (_multi_value_args
    # Required
    TARGET
    # Optional
    ARCHIVE_OPTIONS
    BUNDLE_OPTIONS
    FRAMEWORK_OPTIONS
    LIBRARY_OPTIONS
    RUNTIME_OPTIONS
    CMAKE_CONFIG_FILE_OPTIONS
    CMAKE_CONFIG_VERSION_FILE_OPTIONS
    CMAKE_PACKAGE_FILE_OPTIONS
    )
  set (_one_value_args
    # Optional
    COMMON_TARGET_IDENTIFIER
    CUSTOM_CMAKE_CONFIG_FILE
    CUSTOM_CMAKE_CONFIG_VERSION_FILE
    CUSTOM_PKG_CONFIG_FILE
    CUSTOM_PKG_CONFIG_FILE_OPTIONS
    INSTALL_DEVEL
    INSTALL_RUNTIME
    INSTALL_SOURCES
    NAMESPACE
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  set (_source_extract_regex
    "(\\$<BUILD_INTERFACE:([^>;<$]+)>;\\$<INSTALL_INTERFACE:([^>;<$]+)>)")

  foreach (_target IN LISTS i_TARGET)
    # Install target sources (for all kinds of targets)
    if (i_INSTALL_SOURCES)
      # The INSTALL_SOURCES argument is a workaround to enable not installing
      # sources when they are not needed, for example, when only RUNTIME
      # component is required. This workaround will not work if the files that
      # are required during runtime are listed among other target sources. A
      # workaround for this is creating a separate target for those files.
      _utk_cmake_install_target_sources (TARGET ${_target})
    endif ()

    set (TARGET_NAME "${_target}")

    get_target_property (_target_export_name  "${_target}" EXPORT_NAME)
    get_target_property (_target_type         "${_target}" TYPE)


    # Some properties are not supported for INTERFACE_LIBRARY targets.
    if (_target_type STREQUAL "INTERFACE_LIBRARY")
      set (_target_version ${${PROJECT_NAME}_VERSION})

      if (NOT _target_version)
        message (SEND_ERROR "Provide ${PROJECT_NAME}_VERSION to make installation of the \"${_target}\" INTERFACE_LIBRARY possible.")
      endif ()
    else ()
      get_target_property (_target_is_bundle         "${_target}" BUNDLE)
      get_target_property (_target_is_framework      "${_target}" FRAMEWORK)
      get_target_property (_target_is_macosx_bundle  "${_target}" MACOSX_BUNDLE)

      get_target_property (_target_version      "${_target}" VERSION)
    endif ()

    if (_target_export_name)
      set (_export_options EXPORT "${_target_export_name}")
    else ()
      set (_export_options EXPORT "${_target}")
    endif ()

    # Install runtime files
    if (i_INSTALL_RUNTIME AND
        ((_target_type STREQUAL "EXECUTABLE") OR
          (_target_type STREQUAL "MODULE_LIBRARY") OR
          (_target_type STREQUAL "SHARED_LIBRARY")))
      if (_target_is_bundle OR _target_is_macosx_bundle)

        set (_install_options ${i_BUNDLE_OPTIONS})

      elseif (_target_is_framework)

        set (_install_options ${i_FRAMEWORK_OPTIONS})

      elseif ((_target_type STREQUAL "EXECUTABLE") OR
          (WIN32 AND (_target_type STREQUAL "SHARED_LIBRARY")))

        set (_install_options ${i_RUNTIME_OPTIONS})

      elseif (_target_type STREQUAL "MODULE_LIBRARY")

        set (_install_options ${i_LIBRARY_OPTIONS})

      endif ()

      install (
        TARGETS ${_target}
        ${_install_options}
        )

      unset (_install_options)
    endif ()

    # Install development files
    if (i_INSTALL_DEVEL AND
        ((_target_type STREQUAL "INTERFACE_LIBRARY") OR
          (_target_type STREQUAL "MODULE_LIBRARY") OR
          (_target_type STREQUAL "SHARED_LIBRARY") OR
          (_target_type STREQUAL "STATIC_LIBRARY")))
      if (_target_is_bundle)

        set (_install_options ${i_BUNDLE_OPTIONS})

      elseif (_target_is_framework)

        set (_install_options ${i_FRAMEWORK_OPTIONS})

      elseif (_target_type STREQUAL "MODULE_LIBRARY")

        set (_install_options ${i_LIBRARY_OPTIONS})

      elseif (_target_type STREQUAL "SHARED_LIBRARY")

        if (WIN32)
          set (_install_options ${i_ARCHIVE_OPTIONS})
        else ()
          set (_install_options ${i_LIBRARY_OPTIONS})
        endif ()

      elseif (_target_type STREQUAL "STATIC_LIBRARY")

        set (_install_options ${i_ARCHIVE_OPTIONS})

      endif ()

      # Install libraries
      install (
        TARGETS ${_target}
        ${_export_options}
        ${_install_options}
        )

      # Prepare variables with file names
      string (TOLOWER "${_target}" TARGET_CMAKE_CONFIG_BASE_NAME)

      set (TARGET_CMAKE_CONFIG_TARGETS_FILE_NAME
        "${TARGET_CMAKE_CONFIG_BASE_NAME}-config-targets.cmake")

      set (_target_config_file_name
        "${TARGET_CMAKE_CONFIG_BASE_NAME}-config.cmake")
      set (_target_config_targets_file_name
        "${TARGET_CMAKE_CONFIG_TARGETS_FILE_NAME}")
      set (_target_config_version_file_name
        "${TARGET_CMAKE_CONFIG_BASE_NAME}-config-version.cmake")

      set (_target_config_file
        "${CMAKE_CURRENT_BINARY_DIR}/${_target}/${_target_config_file_name}")

      set (_target_config_targets_file
        "${CMAKE_CURRENT_BINARY_DIR}/${_target}/${_target_config_targets_file_name}")

      set (_target_config_version_file
        "${CMAKE_CURRENT_BINARY_DIR}/${_target}/${_target_config_version_file_name}")

      # Generate package *-config-version.cmake
      if (i_CUSTOM_CMAKE_CONFIG_VERSION_FILE)
        configure_file (
          "${i_CUSTOM_CMAKE_CONFIG_VERSION_FILE}"
          "${_target_config_version_file}"
          ${i_CMAKE_CONFIG_VERSION_FILE_OPTIONS}
          )
      else ()
        write_basic_package_version_file (
          ${_target_config_version_file}
          VERSION       "${_target_version}"
          ${i_CMAKE_CONFIG_VERSION_FILE_OPTIONS}
          )
      endif ()

      # Generate package *-config.cmake
      if (i_CUSTOM_CMAKE_CONFIG_FILE)
        set (_target_config_file_template "${i_CUSTOM_CMAKE_CONFIG_FILE}")
      else ()
        set (_target_config_file_template "${UTK_CMAKE_INSTALL_MODULE_DIR}/utk_cmake_install/cmake-target-config.cmake.in")
      endif ()

      # Configure options to capture TARGET_NAME and any other variables,
      # required by the provided CMAKE_CONFIG_FILE_OPTIONS template string.
      string (CONFIGURE
        "${i_CMAKE_CONFIG_FILE_OPTIONS}"
        _cmake_config_file_options
        @ONLY
        )

      configure_package_config_file (
        "${_target_config_file_template}"
        "${_target_config_file}"
        ${i_CMAKE_CONFIG_FILE_OPTIONS}
        ${_cmake_config_file_options}
        )

      # Configure options to capture TARGET_NAME and any other variables,
      # required by the provided CMAKE_CONFIG_FILE_OPTIONS template string.
      string (CONFIGURE
        "${i_CMAKE_PACKAGE_FILE_OPTIONS}"
        _cmake_package_file_options
        @ONLY
        )

      # Install *-targets[-<BUILD_TYPE>].cmake
      install(
        ${_export_options}
        FILE
        "${_target_config_targets_file_name}"
        ${_cmake_package_file_options}
        )

      # Install other package files
      install(
        FILES
        "${_target_config_file}"
        "${_target_config_version_file}"
        ${_cmake_package_file_options}
        )

      # set (UTK_PC_IN_CONFIGURE_PROJECT_VERSION ${${PROJECT_NAME}_VERSION})
      # configure_file(
      #   "${UTK_CMAKE_INSTALL_MODULE_DIR}/utk_cmake_install/pkg-config.pc.in"
      #   "${CMAKE_CURRENT_BINARY_DIR}/${_target_name}.pc"
      #   @ONLY
      #   )
      # unset (UTK_PC_IN_CONFIGURE_PROJECT_VERSION)

      # install(FILES
      #   ${CMAKE_CURRENT_BINARY_DIR}/${_target_name}.pc
      #   DESTINATION
      #   lib/pkg-config
      #   COMPONENT Devel
      #   )
    endif ()
  endforeach ()
endfunction (utk_cmake_install_project)


######################
# Internal functions #
######################
function (_utk_cmake_install_target_sources)
  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    TARGET
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  _utk_cmake_target_sources_to_install (
    TARGET             ${i_TARGET}
    OUTPUT_ORIGIN      _from_sources
    OUTPUT_DESTINATION _to_sources
    )

  list (LENGTH _from_sources _source_count)
  math (EXPR _iteration_count "${_source_count} - 1")

  foreach (_source_index RANGE ${_iteration_count})
    list (GET _from_sources ${_source_index} _origin_source)
    list (GET _to_sources   ${_source_index} _destination_source)

    # TODO: Implement per-file COMPONENT property
    install (
      FILES       "${_origin_source}"
      DESTINATION "${CMAKE_INSTALL_PREFIX}"
      RENAME      "${_destination_source}"
      )
  endforeach ()
endfunction (_utk_cmake_install_target_sources)


function (_utk_cmake_target_sources_to_install)
  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    TARGET
    OUTPUT_ORIGIN
    OUTPUT_DESTINATION
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  # Check inputs
  utk_cmake_check_required_arguments (
    REQUIRED_ARGUMENT_LIST ${_one_value_args}
    OUTPUT _halt
    )

  if (_halt)
    return ()
  else ()
    unset (_halt)
  endif ()

  # Main logic
  set (_source_extract_regex
    "(\\$<BUILD_INTERFACE:([^>;<$]+)>;\\$<INSTALL_INTERFACE:([^>;<$]+)>)")

  get_target_property (_target_type  "${_target}" TYPE)

  # SOURCES property is not supported for INTERFACE_LIBRARY targets
  if (_target_type STREQUAL "INTERFACE_LIBRARY")
    get_target_property (_target_sources ${i_TARGET} INTERFACE_SOURCES)
  else ()
    get_target_property (_target_sources ${i_TARGET} SOURCES)
  endif ()

  if (_target_sources)
    string (REGEX MATCHALL
      "${_source_extract_regex}"
      _sources_to_install
      "${_target_sources}")

    string (REGEX REPLACE
      "${_source_extract_regex}"
      "\\2"
      _from_sources
      "${_sources_to_install}")

    string (REGEX REPLACE
      "${_source_extract_regex}"
      "\\3"
      _to_sources
      "${_sources_to_install}")

    list (LENGTH _from_source _from_source_count)
    list (LENGTH _to_source _to_source_count)

    if (NOT (_from_source_count EQUAL _to_source_count))
      message (SEND_ERROR "BUILD_INTERFACE declaration count does not match INSTALL_INTERFACE declaration count.")

      return ()
    endif ()
  endif ()

  # Return
  set (${i_OUTPUT_ORIGIN}      ${_from_sources} PARENT_SCOPE)
  set (${i_OUTPUT_DESTINATION} ${_to_sources}   PARENT_SCOPE)
endfunction (_utk_cmake_target_sources_to_install)
