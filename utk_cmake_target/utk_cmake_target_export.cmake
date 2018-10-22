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

include (GenerateExportHeader)

set (UTK_CMAKE_TARGET_EXPORT_SUBMODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_TARGET_EXPORT_SUBMODULE_DIR}/utk_cmake_target_properties.cmake)


define_property (TARGET
  PROPERTY UTK_CMAKE_EXPORT_HEADER
  BRIEF_DOCS "The name of the header file with export macros"
  FULL_DOCS "The value is the file path relative to the target include directory (e.g. /usr/local/include/<UTK_CMAKE_INCLUDE_PREFIX>/<target name>_export.h).")


define_property (TARGET
  PROPERTY UTK_CMAKE_EXPORT_MACRO
  BRIEF_DOCS "The generated export macro"
  FULL_DOCS "The generated export macro.")


# @function utk_cmake_generate_export_header
#
# @brief Generates export header(s) for the given target(s)
#
# @details The function picks MODULE, OBJECT, SHARED or STATIC libraries from
#          the given list and calls the generate_export_header() function from
#          the standard GenerateExportHeader CMake module. If COMMON_BASE_NAME
#          was provided, then it is passed to the generate_export_header() for
#          every target. The following TARGET properties are set for every
#          target: UTK_CMAKE_EXPORT_HEADER is set to the file path for the
#          export header, relative to the include directory root,
#          UTK_CMAKE_EXPORT_MACRO is set to the export macro, generated for the
#          target. If the target is STATIC_LIBRARY then <macro name
#          base>_STATIC_DEFINE is added to target's COMPILE_DEFINITIONS and
#          INTERFACE_COMPILE_DEFINITIONS properties. The export header will not
#          be generated for STATIC_LIBRARY targets if COMMON_BASE_NAME is
#          provided and more then one target is given in TARGET argument to
#          prevent thecommon header from missing proper export macro for shared
#          libraries.
#
# @param [in] TARGET - a list of targets to operate on.
#
# @param [in] CUSTOM_CONTENT_FROM_VARIABLE - passed directly to
#                                            generate_export_header().
#
# @param [in] COMMON_BASE_NAME - passed directly to generate_export_header() as
#                                BASE_NAME argument.
function (utk_cmake_generate_export_header)
  set (_options
    ""
    )
  set (_multi_value_args
    TARGET
    )
  set (_one_value_args
    CUSTOM_CONTENT_FROM_VARIABLE
    COMMON_BASE_NAME
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET argument was not provided")

    return ()
  endif ()

  list (LENGTH i_TARGET _target_count)

  foreach (_target IN LISTS i_TARGET)
    get_target_property (_target_type ${_target} TYPE)

    if (NOT
        (_target_type STREQUAL "MODULE_LIBRARY" OR
          _target_type STREQUAL "OBJECT_LIBRARY" OR
          _target_type STREQUAL "SHARED_LIBRARY" OR
          _target_type STREQUAL "STATIC_LIBRARY"))
      continue ()
    endif ()

    get_target_property (_include_prefix ${_target} UTK_CMAKE_INCLUDE_PREFIX)

    if (NOT _include_prefix)
      message (
        SEND_ERROR
        "Target \"${_target}\" does not provide property UTK_CMAKE_INCLUDE_PREFIX")

      continue ()
    endif ()

    if (i_COMMON_BASE_NAME)
      set (_export_header "${_include_prefix}/${i_COMMON_BASE_NAME}_export.h")
    else ()
      set (_export_header "${_include_prefix}/${_target}_export.h")
    endif ()

    if ((_target_count EQUAL 1) OR
        ((_target_count GREATER 1) AND
          i_COMMON_BASE_NAME AND NOT (_target_type STREQUAL "STATIC_LIBRARY")))
      generate_export_header(${_target}
        EXPORT_FILE_NAME "${_export_header}"
        CUSTOM_CONTENT_FROM_VARIABLE "${i_CUSTOM_CONTENT_FROM_VARIABLE}"
        BASE_NAME "${i_COMMON_BASE_NAME}"
        )
    endif ()

    if (i_COMMON_BASE_NAME)
      set (_export_macro "${i_COMMON_BASE_NAME}_EXPORT")
    else ()
      set (_export_macro "${_target}_EXPORT")
    endif ()

    string (TOUPPER ${_export_macro} _export_macro)

    set_target_properties (
      ${_target}
      PROPERTIES
      UTK_CMAKE_EXPORT_HEADER ${_export_header}
      UTK_CMAKE_EXPORT_MACRO ${_export_macro}
      )

    target_sources (${_target}
      PRIVATE
      $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/${_export_header}>
      $<INSTALL_INTERFACE:include/${_export_header}>)

    if (_target_type STREQUAL "STATIC_LIBRARY")
      if (i_COMMON_BASE_NAME)
        set (_static_define "${i_COMMON_BASE_NAME}_STATIC_DEFINE")
      else ()
        set (_static_define "${_target}_STATIC_DEFINE")
      endif ()

      string (TOUPPER "${_static_define}" _static_define)

      target_compile_definitions (
        ${_target}
        PUBLIC
        ${_static_define}
        )
    else ()
      get_target_property (_define_symbol ${_target} DEFINE_SYMBOL)

      if (NOT _define_symbol)
        if (i_COMMON_BASE_NAME)
          set (_exports_def "${i_COMMON_BASE_NAME}_EXPORTS")
        else ()
          set (_exports_def "${_target}_EXPORTS")
        endif ()

        target_compile_definitions (
          ${_target}
          PRIVATE
          ${_exports_def}
          )
      endif ()
    endif ()
  endforeach (_target IN LISTS i_TARGET)
endfunction (utk_cmake_generate_export_header)
