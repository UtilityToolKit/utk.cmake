#############################################################################
# Copyright 2019 Utility Tool Kit Open Source Contributors                  #
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


cmake_minimum_required (VERSION 3.8 FATAL_ERROR)

set (UTK_CMAKE_TARGET_SOURCE_GROUP_DIR ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_TARGET_SOURCE_GROUP_DIR}/../utk_cmake_utils.cmake)


# @function utk_cmake_target_source_group
#
# @brief Groups target sources from the provided directories for IDE
#
# @param [in] GROUP_INTERFACE_SOURCES - a flag controlling whether the
# INTERFACE_SOURCES will be grouped or not
#
# @param [in] TARGET - a list of targets for which to group sources.
#
# @param [in] ROOT_DIR - a list of directories in which to loook for sources.
#
# @param [in] PREFIX - a source group prefix.
function (utk_cmake_target_source_group)
  set (_options
    GROUP_INTERFACE_SOURCES
    )
  set (_multi_value_args
    # Required
    TARGET
    ROOT_DIR
    )
  set (_one_value_args
    PREFIX
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  # Check inputs
  utk_cmake_check_required_arguments (
    REQUIRED_ARGUMENT_LIST  ${_multi_value_args}
    OUTPUT                  _halt
    )

  if (_halt)
    return ()
  else ()
    unset (_halt)
  endif ()

  foreach (_target IN LISTS i_TARGET)
    if (i_GROUP_INTERFACE_SOURCES)
      get_target_property (_target_sources ${_target} INTERFACE_SOURCES)
    else ()
      get_target_property (_target_sources ${_target} SOURCES)
    endif ()

    # Remove sources to be installed
    set (_source_to_install_regex
      "(\\$<INSTALL_INTERFACE:([^>;<$]+)>)")

    string (REGEX REPLACE
      "${_source_to_install_regex}"
      ""
      _sources_to_build
      "${_target_sources}")

    # Remove remaining ";"s. It seems safer to do it this way rather then include
    # them in _source_to_install_regex
    string (REGEX REPLACE
      "[;]+"
      ";"
      _sources_to_build
      "${_sources_to_build}")

    # Extract sources to be built
    set (_source_to_build_regex
      "\\$<BUILD_INTERFACE:([^>;<$]+)>")

    string (REGEX REPLACE
      "${_source_to_build_regex}"
      "\\1"
      _sources_to_build
      "${_sources_to_build}")

    foreach (_root IN LISTS i_ROOT_DIR)
      set (_sources_under_root_regex
        "${_root}/[^>;<$]+")

      string (REGEX MATCHALL
        "${_sources_under_root_regex}"
        _sources_under_root
        "${_sources_to_build}")

      source_group (
        TREE    "${_root}"
        FILES   ${_sources_under_root}
        PREFIX  "${i_PREFIX}"
        )
    endforeach ()
  endforeach ()
endfunction (utk_cmake_target_source_group)
