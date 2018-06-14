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

set (UTK_CMAKE_TARGET_QT_CONFIGURATION_SUBMODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_TARGET_QT_CONFIGURATION_SUBMODULE_DIR}/utk_cmake_target_properties.cmake)


define_property (TARGET
  PROPERTY UTK_CMAKE_QT_MAX_VERSION
  BRIEF_DOCS "Maximum supported version of Qt framework"
  FULL_DOCS "This value is used to check if it is possible to use the Qt package that has been found. If the property is not provided, then any compatible version of Qt framework can be used.")


define_property (TARGET
  PROPERTY UTK_CMAKE_QT_MIN_VERSION
  BRIEF_DOCS "Minimum supported version of Qt framework"
  FULL_DOCS "This value is used to find Qt package.")


define_property (TARGET
  PROPERTY UTK_CMAKE_QT_OPTIONAL_COMPONENTS
  BRIEF_DOCS "List of the Qt optional components, that are used to build the target"
  FULL_DOCS "At least one REQUIRED or OPTIONAL component must be provided.")


define_property (TARGET
  PROPERTY UTK_CMAKE_QT_REQUIRED_COMPONENTS
  BRIEF_DOCS "List of the Qt components, that are required to build the target"
  FULL_DOCS "At least one REQUIRED or OPTIONAL component must be provided.")


# @function utk_cmake_configure_qt
#
# @brief Finds Qt package and configures the given target to use it based on
#        target's properties
#
# @param [in] TARGET - list of targets to configure Qt for.
#
# @param [in] INTERFACE_LINK_LIBRARIES - when set the Qt libraries are added to
#                                        target's INTERFACE_LINK_LIBRARIES list.
function (utk_cmake_configure_qt)
  set (_options
    INTERFACE_LINK_LIBRARIES
    )
  set (_multi_value_args
    TARGET
    )
  set (_one_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET is not provided")

    return ()
  endif ()

  foreach (_target IN LISTS i_TARGET)
    get_target_property (_qt_min_version
      ${_target}
      UTK_CMAKE_QT_MIN_VERSION)

    get_target_property (_qt_max_version
      ${_target}
      UTK_CMAKE_QT_MAX_VERSION)

    get_target_property (_qt_required_components
      ${_target}
      UTK_CMAKE_QT_REQUIRED_COMPONENTS)

    get_target_property (_qt_optional_components
      ${_target}
      UTK_CMAKE_QT_OPTIONAL_COMPONENTS)

    if (NOT _qt_min_version)
      message (SEND_ERROR "The target \"${_target}\"  does not have UTK_CMAKE_QT_MIN_VERSION property. Impossible to configure Qt.")

      return ()
    endif()

    if (_qt_max_version AND
        (_qt_max_version VERSION_LESS _qt_min_version))
      message (SEND_ERROR "The target \"${_target}\" has misconfigured UTK_CMAKE_QT_MIN_VERSION and UTK_CMAKE_QT_MAX_VERSION: ${_qt_min_version} and ${_qt_max_version} respectively.")
    endif ()

    if (NOT _qt_required_components AND NOT _qt_optional_components)
      message (SEND_ERROR "The target \"${_target}\" has neither UTK_CMAKE_QT_REQUIRED_COMPONENTS nor UTK_CMAKE_QT_OPTIONAL_COMPONENTS property. Impossible to configure Qt.")

      return ()
    endif()

    # Reset <variable name>-NOTFOUND values
    if (NOT _qt_required_components)
      unset (_qt_required_components)
    endif()

    if (NOT _qt_optional_components)
      unset (_qt_optional_components)
    endif()

    if (NOT _qt_max_version)
      unset (_qt_max_version)
    endif ()

    _utk_cmake_qt_find_package (
      TARGET "${_target}"
      QT_MIN_VERSION "${_qt_min_version}"
      QT_MAX_VERSION "${_qt_max_version}"
      QT_REQUIRED_COMPONENTS ${_qt_required_components}
      QT_OPTIONAL_COMPONENTS ${_qt_optional_components}
      )

    _utk_cmake_qt_link_libraries (
      TARGET "${_target}"
      INTERFACE_LINK_LIBRARIES ${i_INTERFACE_LINK_LIBRARIES}
      QT_REQUIRED_COMPONENTS ${_qt_required_components}
      QT_OPTIONAL_COMPONENTS ${_qt_optional_components})
  endforeach ()
endfunction (utk_cmake_configure_qt)


######################
# Internal functions #
######################
function (_utk_cmake_qt_find_package)
  set (_multi_value_args
    QT_REQUIRED_COMPONENTS
    QT_OPTIONAL_COMPONENTS
    )
  set (_one_value_args
    TARGET
    QT_MIN_VERSION
    QT_MAX_VERSION
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if("${i_QT_MIN_VERSION}" MATCHES "^([0-9]+)\\.")
    set(_qt_version_major "${CMAKE_MATCH_1}")
  else()
    set(_qt_version_major ${i_QT_MIN_VERSION})
  endif()

  if ("5" STREQUAL _qt_version_major)
    find_package (Qt5 ${i_QT_MIN_VERSION} REQUIRED
      COMPONENTS
      ${i_QT_REQUIRED_COMPONENTS}
      OPTIONAL_COMPONENTS
      ${i_QT_OPTIONAL_COMPONENTS})

    # Everything in Qt depends on Qt::Core
    if (i_QT_MAX_VERSION AND
        (Qt5Core_VERSION_STRING VERSION_GREATER i_QT_MAX_VERSION))
      message (SEND_ERROR "The version of the Qt package ${Qt5Core_VERSION_STRING} is greater then maximum required version ${i_QT_MAX_VERSION} for target \"${i_TARGET}\"")
    endif ()
  else ()
    message (FATAL_ERROR "Unsupported version of Qt: ${i_QT_MIN_VERSION}")
  endif ()
endfunction (_utk_cmake_qt_find_package)


function (_utk_cmake_qt_link_libraries)
  set (_options "")
  set (_multi_value_args
    QT_REQUIRED_COMPONENTS
    QT_OPTIONAL_COMPONENTS
    )
  set (_one_value_args
    TARGET
    INTERFACE_LINK_LIBRARIES
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  foreach (_component IN LISTS i_QT_REQUIRED_COMPONENTS i_QT_OPTIONAL_COMPONENTS)
    utk_cmake_target_link_libraries (
      TARGET ${i_TARGET}
      PRIVATE
      "Qt5::${_component}"
      )

    if (i_INTERFACE_LINK_LIBRARIES)
      utk_cmake_target_link_libraries (
        TARGET ${i_TARGET}
        INTERFACE
        "Qt5::${_component}"
        )
    endif ()
  endforeach ()
endfunction (_utk_cmake_qt_link_libraries)
