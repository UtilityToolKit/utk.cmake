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


set (UTK_CMAKE_TARGET_NAME_MANGLING_SUBMODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_TARGET_NAME_MANGLING_SUBMODULE_DIR}/../solar-cmake/TargetArch.cmake)


# @function utk_cmake_name_mangling_postfix
#
# @brief Generates name mangling postfixes for the standard build configurations
#        of the target
#
# @details The mangling postfix is set for all standard build
#          configurations. The postfix has the following structure:
#          -${CMAKE_VS_PLATFORM_TOOLSET}-mt-(s|sgd|gd)-<arch>[-<version>]
#          |______________________________|  |  |  |     |   |__________|
#                         |                  |  |  |     |         |
#              Only when built with MSVC.    |  |  |     |         |
#            "mt" stands for multithreaded   |  |  |     |         |
#                    (/MD or /MDd)           |  |  |     |         |
#                                            |  |  |     |         |
#                         Static libraries --+  |  |     |         |
#                Static libraries in debug ---- +  |     |         |
#                            configuration         |     |         |
#      Shared librady or executable in any --------+     |         |
#                of release configurations               |         |
#        Architecture of the target system --------------+         |
#                      Version in the form ------------------------+
#            <major>[_<minor>[_<patch]] if
#              version mangling is enabled
#
# @param [in] TARGET_VERSION_MANGLING - enables version mangling based on the
#                                       target VERSION property.
#
# @param [in] TARGET - list of targets to apply mangling to.
#
# @param [in] ADDITIONAL_POSTFIX - custom additional postfix that is added after
#                                  the generated mangling postfix.
#
# @param [in] PROJECT_VERSION - version of the project that will be used to
#                               perform version mangling.
function (utk_cmake_name_mangling_postfix)
  set (_options
    TARGET_VERSION_MANGLING
    )

  set (_multi_value_args
    TARGET
    ADDITIONAL_POSTFIX
    )
  set (_one_value_args
    PROJECT_VERSION
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_TARGET)
    message (SEND_ERROR "TARGET is not provided")

    return ()
  endif ()

  set (_build_types DEBUG MINSIZEREL RELEASE RELWITHDEBINFO)
  target_architecture (_arch)

  foreach (_target IN LISTS i_TARGET)
    get_target_property (
      _target_type
      ${_target}
      TYPE
      )

    if (DEFINED i_PROJECT_VERSION OR i_TARGET_VERSION_MANGLING)
      if (DEFINED i_PROJECT_VERSION)
        set (_target_version ${i_PROJECT_VERSION})
      elseif (i_TARGET_VERSION_MANGLING)
        get_target_property (
          _target_version
          ${_target}
          VERSION
          )
      endif ()

      if (DEFINED _target_version)
        string (MAKE_C_IDENTIFIER "${_target_version}" _version_mangle)

        string (REGEX REPLACE "^_" "" _version_mangle "${_version_mangle}")
      endif ()
    endif ()

    set (_mangling_postfix "")

    if (MSVC)
      if("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xClang")
        set (_compatible_toolsets "v${MSVC_TOOLSET_VERSION}")

        if("${CMAKE_VS_PLATFORM_TOOLSET}" STREQUAL "LLVM-vs2010")
          list (APPEND _compatible_toolsets "v100")
          set(_predered_toolset "v100")
        elseif("${CMAKE_VS_PLATFORM_TOOLSET}" STREQUAL "LLVM-vs2012")
          list (APPEND _compatible_toolsets "v110")
          set(_predered_toolset "v110")
        elseif("${CMAKE_VS_PLATFORM_TOOLSET}" STREQUAL "LLVM-vs2013")
          list (APPEND _compatible_toolsets "v120")
          set(_predered_toolset "v120")
        elseif("${CMAKE_VS_PLATFORM_TOOLSET}" STREQUAL "LLVM-vs2014")
          list (APPEND _compatible_toolsets "v140;v141")
          set(_predered_toolset "v140")
        endif()

        set ("${_target}_VS_TOOLSET_MANGLING"
          "${_predered_toolset}" CACHE STRING
          "Mangling component to describe the toolset")

        set_property (
          CACHE "${_target}_VS_TOOLSET_MANGLING"
          PROPERTY STRINGS ${_compatible_toolsets})

        set (
          _mangling_postfix
          "${_mangling_postfix}-${${_target}_VS_TOOLSET_MANGLING}-mt")
      else ()
        set (
          _mangling_postfix
          "${_mangling_postfix}-v${MSVC_TOOLSET_VERSION}-mt")
      endif ()
    endif (MSVC)

    if (_target_type STREQUAL "STATIC_LIBRARY")
      set (
        _mangling_postfix
        "${_mangling_postfix}-s")
    endif ()

    foreach (_build_type IN LISTS _build_types)
      set (_build_type_mangling_postfix ${_mangling_postfix})

      if (_build_type STREQUAL "DEBUG")
        if (_target_type STREQUAL "STATIC_LIBRARY")
          set (
            _build_type_mangling_postfix
            "${_build_type_mangling_postfix}gd")
        else ()
          set (
            _build_type_mangling_postfix
            "${_build_type_mangling_postfix}-gd")
        endif ()
      endif ()

      set (_build_type_mangling_postfix
        "${_build_type_mangling_postfix}-${_arch}")

      if (DEFINED _version_mangle)
        set (
          _build_type_mangling_postfix
          "${_build_type_mangling_postfix}-${_version_mangle}")
      endif ()

      if (i_ADDITIONAL_POSTFIX)
        foreach (_postfix IN LISTS i_ADDITIONAL_POSTFIX)
          set (
            _build_type_mangling_postfix
            "${_build_type_mangling_postfix}-${_postfix}")
        endforeach (_postfix IN LISTS i_ADDITIONAL_POSTFIX)
      endif ()

      set_target_properties (
        ${_target}
        PROPERTIES
        ${_build_type}_POSTFIX ${_build_type_mangling_postfix}
        )
    endforeach (_build_type IN LISTS _build_types)
  endforeach ()
endfunction (utk_cmake_name_mangling_postfix)
