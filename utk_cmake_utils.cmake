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


# @function utk_cmake_check_required_arguments
#
# @brief Checks that all of the required arguments were provided to the function
#        in the parent scope
#
# @param [in] REQUIRED_ARGUMENT_LIST - a list of the base names of the function
#                                      arguments that must be defined in the
#                                      parent scope.
#
# @param [in] PREFIX - prefix to format variable names, "i" by default.
#
# @param [out] OUTPUT - the name of the output variable that is set to TRUE if
#                       any of the arguments is mussing.
function (utk_cmake_check_required_arguments)
  set (_options
    ""
    )
  set (_multi_value_args
    REQUIRED_ARGUMENT_LIST
    )
  set (_one_value_args
    PREFIX
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_REQUIRED_ARGUMENT_LIST)
    message (SEND_ERROR "REQUIRED_ARGUMENT_LIST was not provided")

    return ()
  endif ()

  if (NOT i_OUTPUT)
    message (SEND_ERROR "OUTPUT was not provided")

    return ()
  endif ()

  if (i_PREFIX)
    set (_prefix "${i_PREFIX}")
  else ()
    set (_prefix "i")
  endif ()

  set (_missing false)

  foreach (_arg IN LISTS i_REQUIRED_ARGUMENT_LIST)
    if (NOT ${_prefix}_${_arg})
      message (SEND_ERROR "${_arg} was not provided")

      set (_missing true)
    endif ()
  endforeach ()

  set (${i_OUTPUT} ${_missing} PARENT_SCOPE)
endfunction (utk_cmake_check_required_arguments)


# @function utk_cmake_split_version_string
#
# @brief Splits the given version string into 3 integers
#
# @param [in] VERSION_STRING - a version string to split.
#
# @param [out] OUTPUT_MAJOR - the name of the output variable that is set to
#                             return version MAJOR component.
#
# @param [out] OUTPUT_MINOR - the name of the output variable that is set to
#                             return version MINOR component.
#
# @param [out] OUTPUT_PATCH - the name of the output variable that is set to
#                             return version PATCH component.
function (utk_cmake_split_version_string)
  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    VERSION_STRING
    OUTPUT_MAJOR
    OUTPUT_MINOR
    OUTPUT_PATCH
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_VERSION_STRING)
    message (SEND_ERROR "VERSION_STRING was not provided")
  endif ()

  set (_one_part_version_regex   "([0-9]+)")
  set (_two_part_version_regex   "([0-9]+)\\.([0-9]+)")
  set (_three_part_version_regex "([0-9]+)\\.([0-9]+)\\.([0-9]+)")
  set (_four_part_version_regex  "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)")

  if (i_VERSION_STRING MATCHES ${_four_part_version_regex})
    set (_major ${CMAKE_MATCH_1})
    set (_minor ${CMAKE_MATCH_2})
    set (_patch ${CMAKE_MATCH_3})
  elseif (i_VERSION_STRING MATCHES ${_three_part_version_regex})
    set (_major ${CMAKE_MATCH_1})
    set (_minor ${CMAKE_MATCH_2})
    set (_patch ${CMAKE_MATCH_3})
  elseif (i_VERSION_STRING MATCHES ${_two_part_version_regex})
    set (_major ${CMAKE_MATCH_1})
    set (_minor ${CMAKE_MATCH_2})
    set (_patch 0)
  elseif (i_VERSION_STRING MATCHES ${_one_part_version_regex})
    set (_major ${CMAKE_MATCH_1})
    set (_minor 0)
    set (_patch 0)
  else ()
    message (FATAL_ERROR "Malformed version string \"${i_VERSION_STRING}\".")

    return ()
  endif()

  if (i_OUTPUT_MAJOR)
    set (${i_OUTPUT_MAJOR} ${_major} PARENT_SCOPE)
  endif ()

  if (i_OUTPUT_MINOR)
    set (${i_OUTPUT_MINOR} ${_minor} PARENT_SCOPE)
  endif ()

  if (i_OUTPUT_PATCH)
    set (${i_OUTPUT_PATCH} ${_patch} PARENT_SCOPE)
  endif ()
endfunction (utk_cmake_split_version_string)
