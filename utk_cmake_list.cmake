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


cmake_minimum_required (VERSION 3.1)


# @function utk_cmake_list_replace_at
#
# @brief Replaces an item at the given position in list with the given value
#
# @param [in] LIST - a list of values to operate on.
#
# @param [in] INDEX - index of the element to be replaced.
#
# @param [in] VALUE - value to place at INDEX position in LIST.
#
# @param [out] OUTPUT - name of the output variable.
function (utk_cmake_list_replace_at)
  set (_multi_value_args
    LIST
    )
  set (_one_value_args
    INDEX
    VALUE
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  list (INSERT i_LIST ${i_INDEX} ${i_VALUE})

  math (EXPR _old_value_index "${i_INDEX} + 1")

  list (REMOVE_AT i_LIST ${_old_value_index})

  set (${i_OUTPUT} ${i_LIST} PARENT_SCOPE)
endfunction (utk_cmake_list_replace_at)


# @function utk_cmake_named_option_index
#
# @brief Returns the index of the given named option in the given named option
#        list
#
# @param [in] OPTION_LIST - a list of named options to operate on.
#
# @param [in] OPTION_NAME - name of the option to find.
#
# @param [out] OUTPUT - index of the option OPTION_NAME in OPTION_LIST or (-1)
#                       if there is no option with this name.
function (utk_cmake_named_option_index)
  set (_multi_value_args
    OPTION_LIST
    )
  set (_one_value_args
    OPTION_NAME
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  list (FIND i_OPTION_LIST "${i_OPTION_NAME}" _option_index)

  math (EXPR _option_index "${_option_index} + 1")

  set (${i_OUTPUT} ${_option_index} PARENT_SCOPE)
endfunction (utk_cmake_named_option_index)


# @function utk_cmake_get_named_option
#
# @brief Returns the value of the given named option in the given named option
#        list
#
# @param [in] OPTION_LIST - a list of named options to operate on.
#
# @param [in] OPTION_NAME - name of the option to find.
#
# @param [out] OUTPUT - the value of the option OPTION_NAME in OPTION_LIST
function (utk_cmake_get_named_option)
  set (_multi_value_args
    OPTION_LIST
    )
  set (_one_value_args
    OPTION_NAME
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  utk_cmake_named_option_index (
    OPTION_LIST ${i_OPTION_LIST}
    OPTION_NAME "${i_OPTION_NAME}"
    OUTPUT _option_index
    )

  list (GET i_OPTION_LIST ${_option_index} _option_value)

  set (${i_OUTPUT} ${_option_value} PARENT_SCOPE)
endfunction (utk_cmake_get_named_option)


# @function utk_cmake_set_named_option
#
# @brief Sets the value of the given named option in the given named option list
#
# @param [in] OPTION_LIST - a list of named options to operate on.
#
# @param [in] OPTION_NAME - name of the option to set.
#
# @param [in] OPTION_VALUE - new value of the option OPTION_NAME
#
# @param [out] OUTPUT - new value of the OPTION_LIST.
function (utk_cmake_set_named_option)
  set (_multi_value_args
    OPTION_LIST
    )
  set (_one_value_args
    OPTION_NAME
    OPTION_VALUE
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  utk_cmake_named_option_index (
    OPTION_LIST ${i_OPTION_LIST}
    OPTION_NAME "${i_OPTION_NAME}"
    OUTPUT _option_index
    )

  utk_cmake_list_replace_at (
    LIST  ${i_OPTION_LIST}
    INDEX ${_option_index}
    VALUE "${i_OPTION_VALUE}"
    OUTPUT _new_options
    )

  set (${i_OUTPUT} ${_new_options} PARENT_SCOPE)
endfunction (utk_cmake_set_named_option)
