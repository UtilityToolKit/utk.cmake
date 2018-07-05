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


# @function utk_cmake_add_library_targets
#
# @brief Adds multiple library targets and a set of variables in parent scope
#        for working with those targets
#
# @details When both BUILD_SHARED_LIBRARY and BUILD_STATIC_LIBRARY flags
#          evaluates to TRUE, then 2 targets are created: DEFAULT_TARGET_NAME of
#          type DEFAULT_TARGET_TYPE and SECONDARY_TARGET_NAME of the remaining
#          type. If only one of the flags evaluates to TRUE, then only one
#          target is created: DEFAULT_TARGET_NAME of type the type that
#          correspotds to the flag. If <...>_EXPORTED_NAME is provided then
#          property EXPORT_NAME of the respecting target is set.
#
#          The function adds the following variables to parent scope:
#
#          ${OPTION_PREFIX}_TARGET_NAME - equals to DEFAULT_TARGET_NAME
#
#          ${OPTION_PREFIX}_TARGET_TYPE - equals to DEFAULT_TARGET_TYPE if both
#                                         targets are built or to TARGET_TYPE
#                                         for which BUILD_<TARGET_TYPE> is TRUE.
#
#          ${OPTION_PREFIX}_SECONDARY_TARGET_NAME - equals to
#                                                   SECONDARY_TARGET_TYPE (only
#                                                   created if both targets are
#                                                   built)
#
#          ${OPTION_PREFIX}_SECONDARY_TARGET_NAME - equals to
#                                                   SECONDARY_TARGET_TYPE (only
#                                                   created if both targets are
#                                                   built)
#
#          ${i_OPTION_PREFIX}_TARGET_LIST - list of the targets created. This
#                                           list may be used to make target
#                                           processing independent from what
#                                           target created.
#
# @param [in] BUILD_SHARED_LIBRARY - flag that controls creation of
#                                    SHARED_LIBRARY target.
#
# @param [in] BUILD_STATIC_LIBRARY - flag that controls creation of
#                                    STATIC_LIBRARY target.
#
# @param [in] OPTION_PREFIX - a prefix that is used to format names of the
#                             variables that will be added to parent scope
#                             (${PROJECT_NAME} by default).
#
# @param [in] DEFAULT_TARGET_TYPE - type of the target referenced by
#                                   ${OPTION_PREFIX}_TARGET_NAME variable in
#                                   parent scope.
#
# @param [in] DEFAULT_TARGET_NAME - name of the target referenced by
#                                   ${OPTION_PREFIX}_TARGET_NAME variable in
#                                   parent scope.
#
# @param [in] DEFAULT_TARGET_EXPORTED_NAME - exported name of the target
#                                            referenced by
#                                            ${OPTION_PREFIX}_TARGET_NAME
#                                            variable in parent scope.
#
# @param [in] SECONDARY_TARGET_NAME - name of the target referenced by
#                                     ${OPTION_PREFIX}_SECONDARY_TARGET_NAME
#                                     variable in parent scope.
#
# @param [in] SECONDARY_TARGET_EXPORTED_NAME - exported name of the target
#                                              referenced by
#                                              ${OPTION_PREFIX}_TARGET_NAME
#                                              variable in parent scope.
function (utk_cmake_add_library_targets)
  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    OPTION_PREFIX
    BUILD_SHARED_LIBRARY
    BUILD_STATIC_LIBRARY
    DEFAULT_TARGET_TYPE
    DEFAULT_TARGET_NAME
    DEFAULT_TARGET_EXPORTED_NAME
    SECONDARY_TARGET_NAME
    SECONDARY_TARGET_EXPORTED_NAME
    )

  set (_supported_target_types
    SHARED
    STATIC
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_BUILD_SHARED_LIBRARY AND NOT i_BUILD_STATIC_LIBRARY)
    message (
      SEND_ERROR
      "Neither BUILD_SHARED_LIBRARY nor BUILD_STATIC_LIBRARY provided")

    return ()
  endif ()

  if (NOT (i_DEFAULT_TARGET_TYPE IN_LIST _supported_target_types))
    message (SEND_ERROR "Unsupported target type")

    return ()
  endif ()

  if (i_DEFAULT_TARGET_NAME STREQUAL i_SECONDARY_TARGET_NAME)
    message (
      SEND_ERROR
      "DEFAULT_TARGET_NAME and SECONDARY_TARGET_NAME are the same")

    return ()
  endif ()

  if (NOT i_OPTION_PREFIX)
    set (i_OPTION_PREFIX ${PROJECT_NAME})
  endif ()

  set (${i_OPTION_PREFIX}_TARGET_NAME
    "${i_DEFAULT_TARGET_NAME}")

  if (i_BUILD_SHARED_LIBRARY AND i_BUILD_STATIC_LIBRARY)
    set (${i_OPTION_PREFIX}_TARGET_TYPE "${i_DEFAULT_TARGET_TYPE}")

    set (${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME
      "${i_SECONDARY_TARGET_NAME}")

    if (i_DEFAULT_TARGET_TYPE STREQUAL "STATIC")
      set (${i_OPTION_PREFIX}_SECONDARY_TARGET_TYPE SHARED)
    elseif (i_DEFAULT_TARGET_TYPE STREQUAL "SHARED")
      set (${i_OPTION_PREFIX}_SECONDARY_TARGET_TYPE STATIC)
    endif ()

    set (${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME
      "${${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME}" PARENT_SCOPE)
    set (${i_OPTION_PREFIX}_SECONDARY_TARGET_TYPE
      "${${i_OPTION_PREFIX}_SECONDARY_TARGET_TYPE}" PARENT_SCOPE)
  elseif (i_BUILD_SHARED_LIBRARY)
    set (${i_OPTION_PREFIX}_TARGET_TYPE SHARED)
  elseif (i_BUILD_STATIC_LIBRARY)
    set (${i_OPTION_PREFIX}_TARGET_TYPE STATIC)
  endif ()

  set (${i_OPTION_PREFIX}_TARGET_NAME
    "${${i_OPTION_PREFIX}_TARGET_NAME}" PARENT_SCOPE)
  set (${i_OPTION_PREFIX}_TARGET_TYPE
    "${${i_OPTION_PREFIX}_TARGET_TYPE}" PARENT_SCOPE)

  add_library (
    ${${i_OPTION_PREFIX}_TARGET_NAME}
    ${${i_OPTION_PREFIX}_TARGET_TYPE}
    "")

  if (i_DEFAULT_TARGET_EXPORTED_NAME)
    set_target_properties (${${i_OPTION_PREFIX}_TARGET_NAME}
      PROPERTIES
      EXPORT_NAME ${i_DEFAULT_TARGET_EXPORTED_NAME}
      )
  else ()
    set_target_properties (${${i_OPTION_PREFIX}_TARGET_NAME}
      PROPERTIES
      EXPORT_NAME ${${i_OPTION_PREFIX}_TARGET_NAME}
      )
  endif ()

  if (${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME AND
      (i_BUILD_SHARED_LIBRARY AND i_BUILD_STATIC_LIBRARY))
    add_library (
      ${${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME}
      ${${i_OPTION_PREFIX}_SECONDARY_TARGET_TYPE}
      "")

    if (i_SECONDARY_TARGET_EXPORTED_NAME)
      set_target_properties (${${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME}
        PROPERTIES
        EXPORT_NAME ${i_SECONDARY_TARGET_EXPORTED_NAME}
        )
    else ()
      set_target_properties (${${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME}
        PROPERTIES
        EXPORT_NAME ${${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME}
        )
    endif ()
  endif ()

  if (i_BUILD_SHARED_LIBRARY AND i_BUILD_STATIC_LIBRARY)
    set (${i_OPTION_PREFIX}_TARGET_LIST
      "${${i_OPTION_PREFIX}_TARGET_NAME}"
      "${${i_OPTION_PREFIX}_SECONDARY_TARGET_NAME}" PARENT_SCOPE)
  else ()
    set (${i_OPTION_PREFIX}_TARGET_LIST
      "${${i_OPTION_PREFIX}_TARGET_NAME}" PARENT_SCOPE)
  endif ()
endfunction (utk_cmake_add_library_targets)


# @function utk_cmake_set_library_properties
#
# @brief Sets properties of the given targets based on each target's type
#
# @details Format of the <TARGET_TYPE>_PROPERTIES list is the same as for
#          set_target_properties() function with exception to list property
#          values that are not supported.
#
# @param [in] TARGET - list of targets to operate on.
#
# @param [in] MODULE_LIBRARY_PROPERTIES - list of properties that should be set
#                                         for MODULE_LIBRARY target if one is
#                                         provided.
#
# @param [in] OBJECT_LIBRARY_PROPERTIES - list of properties that should be set
#                                         for OBJECT_LIBRARY target if one is
#                                         provided.
#
# @param [in] SHARED_LIBRARY_PROPERTIES - list of properties that should be set
#                                         for SHARED_LIBRARY target if one is
#                                         provided.
#
# @param [in] STATIC_LIBRARY_PROPERTIES - list of properties that should be set
#                                         for STATIC_LIBRARY target if one is
#                                         provided.
function (utk_cmake_set_library_properties)
  set (_options
    ""
    )
  set (_multi_value_args
    TARGET
    MODULE_LIBRARY_PROPERTIES
    OBJECT_LIBRARY_PROPERTIES
    SHARED_LIBRARY_PROPERTIES
    STATIC_LIBRARY_PROPERTIES
    )
  set (_one_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET argument was not provided")

    return ()
  endif()

  if (NOT
      (i_MODULE_LIBRARY_PROPERTIES OR
        i_OBJECT_LIBRARY_PROPERTIES OR
        i_SHARED_LIBRARY_PROPERTIES OR
        i_STATIC_LIBRARY_PROPERTIES))
    message (SEND_ERROR "None of the arguments was provided: MODULE_LIBRARY_PROPERTIES
    OBJECT_LIBRARY_PROPERTIES
    SHARED_LIBRARY_PROPERTIES
    STATIC_LIBRARY_PROPERTIES")

    return ()
  endif()

  foreach (_target IN LISTS i_TARGET)
    get_target_property (_target_type ${_target} TYPE)

    if ((_target_type STREQUAL "MODULE_LIBRARY") AND
        i_MODULE_LIBRARY_PROPERTIES)
      set_target_properties (${_target}
        PROPERTIES
        ${i_MODULE_LIBRARY_PROPERTIES}
        )
    elseif ((_target_type STREQUAL "OBJECT_LIBRARY") AND
        i_OBJECT_LIBRARY_PROPERTIES)
      set_target_properties (${_target}
        PROPERTIES
        ${i_OBJECT_LIBRARY_PROPERTIES}
        )
    elseif ((_target_type STREQUAL "SHARED_LIBRARY") AND
        i_SHARED_LIBRARY_PROPERTIES)
      set_target_properties (${_target}
        PROPERTIES
        ${i_SHARED_LIBRARY_PROPERTIES}
        )
    elseif (
        (_target_type STREQUAL "STATIC_LIBRARY") AND
        i_STATIC_LIBRARY_PROPERTIES)
      set_target_properties (${_target}
        PROPERTIES
        ${i_STATIC_LIBRARY_PROPERTIES}
        )
    endif ()
  endforeach ()
endfunction (utk_cmake_set_library_properties)
