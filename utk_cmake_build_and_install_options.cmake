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


# @function utk_cmake_build_and_install_options
#
# @brief Adds options to configure building and installation of the project
#        targets
#
# @details EXECUTABLE, SHARED_LIBRARY and MODULE_LIBRARY targets have
#          ${OPTION_PREFIX}_INSTALL_RUNTIME option.
#
#          SHARED_LIBRARY and STATIC_LIBRARY targets have
#          ${OPTION_PREFIX}_INSTALL_DEVEL option.
#
#          If both SHARED_LIBRARY and STATIC_LIBRARY targets are used then
#          options for choosing which target to build are added. Their default
#          values are controlled by SHARED_LIBRARY_ENABLED and
#          STATIC_LIBRARY_ENABLED function arguments.
#
# @param [in] EXECUTABLE - add options for EXECUTABLE target type.
#
# @param [in] MODULE_LIBRARY - add options for MODULE_LIBRARY target type.
#
# @param [in] SHARED_LIBRARY - add options for SHARED_LIBRARY target type.
#
# @param [in] SHARED_LIBRARY_ENABLED - the default value of the flag for
#                                      building SHARED_LIBRARY target type.
#
# @param [in] STATIC_LIBRARY - add options for STATIC_LIBRARY target type.
#
# @param [in] STATIC_LIBRARY_ENABLED - the default value of the flag for
#                                      building STATIC_LIBRARY target type.
#
# @param [in] TESTS - add options for building and installing tests.
#
# @param [in] TESTS_ENABLED - the default value of the flag for building tests.
#
# @param [in] OPTION_PREFIX - a prefix used to format option names. If a prefix
#                             is not provided then the ${PROJECT_NAME} is used.
function (utk_cmake_build_and_install_options)
  set (_options
    BENCHMARKS
    BENCHMARKS_ENABLED
    EXAMPLES
    EXECUTABLE
    INSTALL_DEVEL
    INTERFACE_LIBRARY
    MODULE_LIBRARY
    SHARED_LIBRARY
    SHARED_LIBRARY_ENABLED
    STATIC_LIBRARY
    STATIC_LIBRARY_ENABLED
    TESTS
    TESTS_ENABLED
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    OPTION_PREFIX
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT i_OPTION_PREFIX)
    set (i_OPTION_PREFIX ${PROJECT_NAME})
  endif ()

  if (NOT
      (i_EXECUTABLE OR
        i_INTERFACE_LIBRARY OR
        i_MODULE_LIBRARY OR
        i_SHARED_LIBRARY OR
        i_STATIC_LIBRARY OR
        i_TESTS OR
        i_BENCHMARKS))
    message (SEND_ERROR "No options provided")

    return ()
  endif ()

  if (i_EXECUTABLE OR i_SHARED_LIBRARY OR i_MODULE_LIBRARY)
    option (${i_OPTION_PREFIX}_INSTALL_RUNTIME "Install runtime files (shared libraries (*.so, *.dll) and executables)" true)
  else ()
    set (${i_OPTION_PREFIX}_INSTALL_RUNTIME false PARENT_SCOPE)
  endif ()

  if (i_INTERFACE_LIBRARY OR
      i_SHARED_LIBRARY OR
      i_STATIC_LIBRARY OR
      i_INSTALL_DEVEL)
    option (${i_OPTION_PREFIX}_INSTALL_DEVEL "Install development files (headers, libraries, CMake and pkg-config package files)" true)
  else ()
    set (${i_OPTION_PREFIX}_INSTALL_DEVEL false PARENT_SCOPE)
  endif ()

  if (i_SHARED_LIBRARY AND i_STATIC_LIBRARY)
    option (${i_OPTION_PREFIX}_BUILD_SHARED_LIBRARY
      "Build the shared library" ${i_SHARED_LIBRARY_ENABLED})
    option (${i_OPTION_PREFIX}_BUILD_STATIC_LIBRARY
      "Build the static library" ${i_STATIC_LIBRARY_ENABLED})

    if (NOT ${i_OPTION_PREFIX}_BUILD_SHARED_LIBRARY AND
        NOT ${i_OPTION_PREFIX}_BUILD_STATIC_LIBRARY)
      message (SEND_ERROR "Set ${i_OPTION_PREFIX}_BUILD_SHARED_LIBRARY or ${i_OPTION_PREFIX}_BUILD_STATIC_LIBRARY build option.")
    endif ()
  elseif (i_SHARED_LIBRARY)
    set (${i_OPTION_PREFIX}_BUILD_SHARED_LIBRARY true PARENT_SCOPE)
    set (${i_OPTION_PREFIX}_BUILD_STATIC_LIBRARY false PARENT_SCOPE)
  elseif (i_STATIC_LIBRARY)
    set (${i_OPTION_PREFIX}_BUILD_SHARED_LIBRARY false PARENT_SCOPE)
    set (${i_OPTION_PREFIX}_BUILD_STATIC_LIBRARY true PARENT_SCOPE)
  endif ()

  if (i_TESTS)
    option (${i_OPTION_PREFIX}_BUILD_TESTS
      "Build tests" ${i_TESTS_ENABLED})
    option (${i_OPTION_PREFIX}_INSTALL_TESTS
      "Install tests with other executables" false)
  endif ()

  if (i_BENCHMARKS)
    option (${i_OPTION_PREFIX}_BUILD_BENCHMARKS
      "Build tests" ${i_BENCHMARKS_ENABLED})
    option (${i_OPTION_PREFIX}_INSTALL_BENCHMARKS
      "Install tests with other executables" false)
  endif ()

  if (i_EXAMPLES)
    option (${i_OPTION_PREFIX}_BUILD_EXAMPLES
      "Build examples" ${i_EXAMPLES_ENABLED})
    option (${i_OPTION_PREFIX}_INSTALL_EXAMPLES
      "Install examples with other executables" false)
  endif ()
endfunction (utk_cmake_build_and_install_options)
