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


define_property (TARGET
  PROPERTY UTK_CMAKE_INCLUDE_PREFIX
  BRIEF_DOCS "Prefix added to all target file names"
  FULL_DOCS "This is the part of path between include root and target header files (e.g. /usr/local/include/<UTK_CMAKE_INCLUDE_PREFIX>/<header file name>).")


define_property (TARGET
  PROPERTY UTK_CMAKE_SET_PROPERTIES
  BRIEF_DOCS "A list of properties that were set with utk_cmake_set_target_properties function"
  FULL_DOCS "This list can later be used to sync properties between targets.")


# @function utk_cmake_sync_target_properties
#
# @brief Synchronises property values between two targets
#
# @param [in] OVERRIDE_MATCHING - if set then properties of the CHILD_TARGET are
#                                 overwritten with the PARENT_TARGET property
#                                 values, otherwise the PARENT_TARGET property
#                                 values are appended to the values of the
#                                 corresponding properties of the CHILD_TARGET.
#
# @param [in] IGNORE_UTK_CMAKE_SET_PROPERTIES - ignores properties that are
#                                               listed in
#                                               UTK_CMAKE_SET_PROPERTIES target
#                                               property.
#
# @param [in] PROPERTIES_TO_SYNC - list of properties that should be
#                                  synchronised.
#
# @param [in] PARENT_TARGET - the target that is used as a source of property
#                             values.
#
# @param [in] CHILD_TARGET - the target whose properties should be changed.
function (utk_cmake_sync_target_properties)
  set (_options
    OVERRIDE_MATCHING
    IGNORE_UTK_CMAKE_SET_PROPERTIES
    )
  set (_multi_value_args
    PROPERTIES_TO_SYNC
    )
  set (_one_value_args
    PARENT_TARGET
    CHILD_TARGET
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_PROPERTIES_TO_SYNC AND i_IGNORE_UTK_CMAKE_SET_PROPERTIES)
    message (SEND_ERROR "No properties to sync")

    return ()
  endif()

  if (NOT (i_PARENT_TARGET AND i_CHILD_TARGET))
    message (SEND_ERROR "Required arguments are not provided")

    return ()
  endif ()

  set (_properties_to_sync ${i_PROPERTIES_TO_SYNC})

  if (NOT i_IGNORE_UTK_CMAKE_SET_PROPERTIES)
    get_target_property (
      _utk_cmake_set_properties
      ${i_PARENT_TARGET}
      UTK_CMAKE_SET_PROPERTIES
      )

    list (APPEND _properties_to_sync ${_utk_cmake_set_properties})
    list (REMOVE_DUPLICATES _properties_to_sync)
  endif ()

  foreach (_property IN LISTS _properties_to_sync)
    if (i_OVERRIDE_MATCHING)
      get_target_property (
        _parent_property_value
        ${i_PARENT_TARGET}
        ${_property}
        )

      if (_parent_property_value)
        set_property (
          TARGET ${i_CHILD_TARGET}
          PROPERTY ${_property} ${_parent_property_value})
      endif ()
    else ()
      get_target_property (
        _parent_property_value
        ${i_PARENT_TARGET}
        ${_property}
        )

      if (_parent_property_value)
        set_property (
          TARGET ${i_CHILD_TARGET}
          APPEND
          PROPERTY ${_property} ${_parent_property_value})
      endif ()
    endif ()
  endforeach ()
endfunction (utk_cmake_sync_target_properties)


# @function utk_cmake_target_include_directories
#
# @brief The same as target_include_directories()
#
# @details Arguments are the same as for the target_include_directories() function
#          with the exception to TARGET that may be a list.
function (utk_cmake_target_include_directories)
  set (_options "")
  set (_multi_value_args
    TARGET
    PRIVATE
    PUBLIC
    INTERFACE
    )
  set (_one_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET argument was not provided")

    return ()
  endif ()

  foreach (_target IN LISTS i_TARGET)
    target_include_directories (${_target}
      INTERFACE
      ${i_INTERFACE}
      PRIVATE
      ${i_PRIVATE}
      PUBLIC
      ${i_PUBLIC}
      )
  endforeach (_target IN LISTS i_TARGET)
endfunction (utk_cmake_target_include_directories)


# @function utk_cmake_target_link_libraries
#
# @brief The same as target_link_libraries() but works on OBJECT_LIBRARY targets
#
# @details Arguments are the same as for the target_link_libraries() function
#          with the exception to TARGET that may be a list.
function (utk_cmake_target_link_libraries)
  set (_options "")
  set (_multi_value_args
    TARGET
    PRIVATE
    PUBLIC
    INTERFACE
    )
  set (_one_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET argument was not provided")

    return ()
  endif ()

  foreach (_target IN LISTS i_TARGET)
    get_target_property (_target_type ${_target} TYPE)

    if (_target_type STREQUAL "OBJECT_LIBRARY")
      set (_interface_link ${i_INTERFACE} ${i_PUBLIC})
      set (_link ${i_PUBLIC} ${i_PRIVATE})

      foreach (_library IN LISTS _interface_link)
        set_property (
          TARGET ${_target}
          APPEND
          PROPERTY LINK_LIBRARIES ${_library})

        set_property (
          TARGET ${_target}
          APPEND
          PROPERTY INTERFACE_LINK_LIBRARIES ${_library})
      endforeach ()

      foreach (_library IN LISTS _link)
        set_property (
          TARGET ${_target}
          APPEND
          PROPERTY LINK_LIBRARIES ${_library})
      endforeach ()
    elseif (
        _target_type STREQUAL "EXECUTABLE" OR
        _target_type STREQUAL "MODULE_LIBRARY" OR
        _target_type STREQUAL "SHARED_LIBRARY" OR
        _target_type STREQUAL "STATIC_LIBRARY")
      target_link_libraries (${_target}
        INTERFACE
        ${i_INTERFACE}
        PRIVATE
        ${i_PRIVATE}
        PUBLIC
        ${i_PUBLIC}
        )
    else ()
      message (SEND_ERROR "Unsupported target type \"${_target_type}\"")
    endif ()
  endforeach (_target IN LISTS i_TARGET)
endfunction (utk_cmake_target_link_libraries)


# @function utk_cmake_target_sources
#
# @brief The same as target_sources()
#
# @details Arguments are the same as for the target_sources() function
#          with the exception to TARGET that may be a list.
function (utk_cmake_target_sources)
  set (_options "")
  set (_multi_value_args
    TARGET
    PRIVATE
    PUBLIC
    INTERFACE
    )
  set (_one_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET argument was not provided")

    return ()
  endif ()

  foreach (_target IN LISTS i_TARGET)
    target_sources (${_target}
      INTERFACE
      ${i_INTERFACE}
      PRIVATE
      ${i_PRIVATE}
      PUBLIC
      ${i_PUBLIC}
      )
  endforeach (_target IN LISTS i_TARGET)
endfunction (utk_cmake_target_sources)
