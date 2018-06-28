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


set (UTK_CMAKE_PRODUCT_MODULE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_PRODUCT_MODULE_DIRECTORY}/utk_cmake_utils.cmake)

if (WIN32)
  include (${UTK_CMAKE_PRODUCT_MODULE_DIRECTORY}/CMakeHelpers/generate_product_version.cmake)
endif ()


# Common target properties
define_property (TARGET
  PROPERTY UTK_CMAKE_GIT_DESCRIBE
  BRIEF_DOCS "Advanced version info for developers"
  FULL_DOCS "String with information that is important for developers during
  development process. This information includes git commit hash, durty status
  of repo, distance from the last tag.")

define_property (TARGET
  PROPERTY UTK_CMAKE_GIT_UNTRACKED_FILES
  BRIEF_DOCS "Information about presence of untracked files"
  FULL_DOCS "Used in helper functions generation to add .with-untracked suffix
  to version string. Suffix is only added if there are some untracked not
  ignored files in repository.")

define_property (TARGET
  PROPERTY UTK_CMAKE_LANGUAGE
  BRIEF_DOCS "The main target programming language"
  FULL_DOCS "This property is used to generate version information functions in the way that suits the language best.")

define_property (TARGET
  PROPERTY UTK_CMAKE_PROJECT_CXX_NAMESPACE
  BRIEF_DOCS "A list that represents hierarchy of the main project namespace"
  FULL_DOCS "Each item in the list represents a namespace that is nested inside the namespace, named by the previous list item. If the item value is \"inline\" then the next item represents the namespace with the \"inline\" attribute.")

define_property (TARGET
  PROPERTY UTK_CMAKE_PROJECT_INFO_HEADER
  BRIEF_DOCS "The name of the header with generated project information functions"
  FULL_DOCS "The property is only set if project information functions were generated.")

# INTERFACE_LIBRARY target properties
define_property (TARGET
  PROPERTY INTERFACE_UTK_CMAKE_GIT_DESCRIBE
  BRIEF_DOCS "Advanced version info for developers"
  FULL_DOCS "String with information that is important for developers during
  development process. This information includes git commit hash, durty status
  of repo, distance from the last tag. This property is intended to be used with INTERFACE_LIBRARY targets.")

define_property (TARGET
  PROPERTY INTERFACE_UTK_CMAKE_GIT_UNTRACKED_FILES
  BRIEF_DOCS "Information about presence of untracked files"
  FULL_DOCS "Used in helper functions generation to add .with-untracked suffix
  to version string. Suffix is only added if there are some untracked not
  ignored files in repository. This property is intended to be used with INTERFACE_LIBRARY targets.")

define_property (TARGET
  PROPERTY INTERFACE_UTK_CMAKE_LANGUAGE
  BRIEF_DOCS "The main target programming language"
  FULL_DOCS "This property is used to generate version information functions in the way that suits the language best. This property is intended to be used with INTERFACE_LIBRARY targets.")

define_property (TARGET
  PROPERTY INTERFACE_UTK_CMAKE_PROJECT_CXX_NAMESPACE
  BRIEF_DOCS "A list that represents hierarchy of the main project namespace"
  FULL_DOCS "Each item in the list represents a namespace that is nested inside the namespace, named by the previous list item. If the item value is \"inline\" then the next item represents the namespace with the \"inline\" attribute. This property is intended to be used with INTERFACE_LIBRARY targets.")

define_property (TARGET
  PROPERTY INTERFACE_UTK_CMAKE_PROJECT_INFO_HEADER
  BRIEF_DOCS "The name of the header with generated project information functions"
  FULL_DOCS "The property is only set if project information functions were generated. This property is intended to be used with INTERFACE_LIBRARY targets.")


# @function utk_cmake_product_information
#
# @brief Generates product information functions and adds product information
#        resources when on Win32
#
# @details The <...>_(FILE|STRING) arguments are required to provide support of
#          local encodings. This is required to properly support product
#          information embedding on Win32 platforms. If it is not desired for
#          the CMakeLists.txt of the project to be encoded in the local system
#          encoding, then the information for product information resource may
#          be provided in separate files.
#
#          The Win32 resources are generated with the generate_product_version()
#          function from (https://github.com/bwrsandman/CMakeHelpers.git)
#
#          The function uses the following TARGET properties:
#
#           * TYPE
#
#           * VERSION - used to generate version information;
#                       ${PROJECT_NAME}_VERSION is used, if the property is not
#                       set;
#
#           * UTK_CMAKE_PROJECT_CXX_NAMESPACE - used to generate namespace or
#                                               name prefix for the project
#                                               information functions;
#
#           * UTK_CMAKE_INCLUDE_PREFIX - used to generate header file inclusion
#                                        guard and set header file
#                                        INSTALL_INTERFACE property;
#
#           * UTK_CMAKE_EXPORT_HEADER - used to get access to the target's
#                                       export macro;
#
#           * UTK_CMAKE_EXPORT_MACRO - user to export generated functions;
#
#           * C(XX)_EXTENSIONS - used to determine target language;
#
#           * C(XX)_STANDARD - used to determine target language;
#
#           * LINKED_LANGUAGE - used to determine target language.
#
#          The function uses the following GLOBAL properties:
#
#           * ENABLED_LANGUAGES - used to determine target language.
#
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
function (utk_cmake_product_information)
  string (TIMESTAMP UTK_CMAKE_CURRENT_YEAR "%Y")

  set (_options
    CREATE_PRODUCT_INFO_FUNCTIONS
    )
  set (_multi_value_args
    TARGET
    )
  set (_one_value_args
    COMMON_TARGET_IDENTIFIER
    ICON
    USE_ICON
    )
  # Data to generate additional one value argument names
  set (_optional_file_arguments
    CONTRIBUTORS
    LICENSE
    NOTICE
    )
  set (_optional_file_or_string_arguments
    BUNDLE
    COMMENTS
    COPYRIGHT_INFO
    COPYRIGHT_INFO_UTF8
    FILE_DESCRIPTION
    INTERNAL_NAME
    LICENSE_NAME
    ORIGINAL_FILENAME
    )
  set (_required_file_or_string_arguments
    COPYRIGHT_HOLDER
    NAME
    )
  set (_file_or_string_arguments
    ${_optional_file_or_string_arguments}
    ${_required_file_or_string_arguments}
    )

  # Generate additional one value argument names
  foreach (_argument_base_name IN LISTS _optional_file_arguments)
    list (APPEND _one_value_args
      "${_argument_base_name}_FILE")
  endforeach ()

  foreach (_argument_base_name IN LISTS _file_or_string_arguments)
    list (APPEND _one_value_args
      "${_argument_base_name}_FILE"
      "${_argument_base_name}_STRING")
  endforeach ()

  # Parse given arguments
  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  # Process generated one value arguments
  foreach (_required_argument IN LISTS _required_file_or_string_arguments)
    string (TOLOWER "_${_required_argument}" _variable_name)

    if (i_${_required_argument}_STRING)
      set (${_variable_name} ${i_${_required_argument}_STRING})
    elseif (i_${_required_argument}_FILE)
      file (READ ${i_${_required_argument}_FILE} ${_variable_name})
    else ()
      message (SEND_ERROR "No ${_required_argument} provided")
    endif ()
  endforeach ()

  foreach (_optional_argument IN LISTS _optional_file_or_string_arguments)
    string (TOLOWER "_${_optional_argument}" _variable_name)

    if (i_${_optional_argument}_STRING)
      set (${_variable_name} ${i_${_optional_argument}_STRING})
    elseif (i_${_optional_argument}_FILE)
      file (READ ${i_${_optional_argument}_FILE} ${_variable_name})
    endif ()
  endforeach ()

  foreach (_file_argument IN LISTS _optional_file_arguments)
    string (TOLOWER "_${_file_argument}" _variable_name)

    if (i_${_file_argument}_FILE)
      file (READ ${i_${_file_argument}_FILE} ${_variable_name})
    endif ()
  endforeach ()

  # If the copyright info was given then it should be configured to place
  # current year into it.
  string (CONFIGURE "${_copyright_info}"      _copyright_info)
  string (CONFIGURE "${_copyright_info_utf8}" _copyright_info_utf8)

  # If the license was provided then its name should have been provided too.
  if (_license AND NOT _license_name)
    message (SEND_ERROR "No license name provided")
  endif ()

  # Main function logic starts here
  if (NOT i_TARGET)
    message (SEND_ERROR "No TARGET argument provided")

    return ()
  endif ()

  foreach (_target IN LISTS i_TARGET)
    get_target_property (_target_type ${_target} TYPE)

    if (i_CREATE_PRODUCT_INFO_FUNCTIONS)
      _utk_cmake_target_git_information (TARGET "${_target}")

      _utk_cmake_target_info_functions (
        TARGET                    "${_target}"
        COMMON_TARGET_IDENTIFIER  "${i_COMMON_TARGET_IDENTIFIER}"
        CONTRIBUTORS              "${_contributors}"
        COPYRIGHT_INFO            "${_copyright_info_utf8}"
        LICENSE                   "${_license}"
        LICENSE_NAME              "${_license_name}"
        NOTICE                    "${_notice}"
        )
    endif (i_CREATE_PRODUCT_INFO_FUNCTIONS)

    if (WIN32 AND
        NOT (
          (_target_type STREQUAL "INTERFACE_LIBRARY") OR
          (_target_type STREQUAL "STATIC_LIBRARY")))
      _utk_cmake_target_version (
        TARGET  "${_target}"
        VERSION _target_version
        )

      utk_cmake_split_version_string (
        VERSION_STRING  "${_target_version}"
        OUTPUT_MAJOR    _version_major
        OUTPUT_MINOR    _version_minor
        OUTPUT_PATCH    _version_patch
        )

      generate_product_version (
	    win32VersionInfoFiles
	    NAME               "${_name}"
        BUNDLE             "${_bundle}"
        USE_ICON           "${i_USE_ICON}"
        ICON               "${i_ICON}"
	    VERSION_MAJOR      "${_version_major}"
	    VERSION_MINOR      "${_version_minor}"
	    VERSION_PATCH      "${_version_patch}"
	    COMPANY_NAME       "${_copyright_holder}"
        COMPANY_COPYRIGHT  "${_copyright_info}"
	    COMMENTS           "${_comments}"
	    ORIGINAL_FILENAME  "${_original_filename}"
	    INTERNAL_NAME      "${_internal_filename}"
	    FILE_DESCRIPTION   "${_file_description}"
        )

      target_sources (${_target}
	    PRIVATE
	    ${win32VersionInfoFiles})
    endif ()
  endforeach ()
endfunction (utk_cmake_product_information)


######################
# Internal functions #
######################
function (_utk_cmake_format_cxx_namespace)
  set (_options
    ""
    )
  set (_one_value_args
    NAMESPACE_BEGIN
    NAMESPACE_END
    )
  set (_multi_value_args
    NESTED_NAMESPACE_LIST
    )
  set (_required_arguments
    ${_one_value_args}
    ${_multi_value_args}
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  utk_cmake_check_required_arguments (
    REQUIRED_ARGUMENT_LIST ${_required_arguments}
    OUTPUT _halt
    )

  if (_halt)
    return ()
  else ()
    unset (_halt)
  endif ()

  # Nested namespace begin
  set (_nested_namespace_list ${i_NESTED_NAMESPACE_LIST})
  set (_cxx_namespace_begin "${_nested_namespace_list}")

  string (REPLACE
    ";inline;" " {\ninline namespace "
    _cxx_namespace_begin "${_cxx_namespace_begin}")

  string (REPLACE
    ";" " {\nnamespace " _cxx_namespace_begin "${_cxx_namespace_begin}")

  set (_cxx_namespace_begin "namespace ${_cxx_namespace_begin}")

  set (_cxx_namespace_begin "${_cxx_namespace_begin} {")

  # Nested namespace end
  list (REMOVE_ITEM _nested_namespace_list "inline")

  list (LENGTH _nested_namespace_list _nested_namespace_count)

  set (_cxx_namespace_end "")

  foreach (_i RANGE 1 ${_nested_namespace_count})
    set (_cxx_namespace_end "${_cxx_namespace_end}\n}")
  endforeach ()

  # Return
  set (${i_NAMESPACE_BEGIN} ${_cxx_namespace_begin} PARENT_SCOPE)
  set (${i_NAMESPACE_END} ${_cxx_namespace_end} PARENT_SCOPE)
endfunction (_utk_cmake_format_cxx_namespace)


function (_utk_cmake_target_function_name_prefix)
  set (_options
    ""
    )
  set (_required_one_value_args
    TARGET
    OUTPUT
    )
  set (_one_value_args
    ${_required_one_value_args}
    COMMON_TARGET_IDENTIFIER
    )
  set (_multi_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  utk_cmake_check_required_arguments (
    REQUIRED_ARGUMENT_LIST ${_required_one_value_args}
    OUTPUT _halt
    )

  if (_halt)
    return ()
  else ()
    unset (_halt)
  endif ()

  set (_target_function_name_prefix "")

  if (i_COMMON_TARGET_IDENTIFIER)
    set (_prefix_base "${i_COMMON_TARGET_IDENTIFIER}")
  else ()
    set (_prefix_base "${i_TARGET}")
  endif ()

  _utk_cmake_target_language (
    TARGET "${i_TARGET}"
    LANGUAGE _target_language
    )

  get_target_property (_target_type "${i_TARGET}" TYPE)

  if (_target_type STREQUAL "INTERFACE_LIBRARY")
    set (_property_name_prefix "INTERFACE_")
  endif ()

  get_target_property (
    _target_namespace "${i_TARGET}"
    ${_property_name_prefix}UTK_CMAKE_PROJECT_CXX_NAMESPACE)

  _utk_cmake_target_version (
    TARGET  "${_target}"
    VERSION _target_version
    )

  # Main logic
  set (_supported_languages "C" "CXX" "UNDEFINED")

  if (_target_language IN_LIST _supported_languages)
    if (_target_namespace AND NOT (_target_language STREQUAL "CXX"))
      list (REMOVE_ITEM _target_namespace "inline")

      string (MAKE_C_IDENTIFIER "${_target_namespace}" _target_function_name_prefix)
    elseif (_target_version AND (_target_type STREQUAL "INTERFACE_LIBRARY"))
      string (MAKE_C_IDENTIFIER "${_target_version}" _version_prefix)

      set (_target_function_name_prefix "${_prefix_base}${_version_prefix}")
    else ()
      string (MAKE_C_IDENTIFIER "${_prefix_base}" _target_function_name_prefix)
    endif ()

    if (_target_type STREQUAL "INTERFACE_LIBRARY")
      set (_target_function_name_prefix "inline ${_target_function_name_prefix}")
    endif ()
  else ()
    message (SEND_ERROR "Unsupported language \"${_target_language}\"")

    return ()
  endif ()

  # Return
  set (${i_OUTPUT} "${_target_function_name_prefix}_" PARENT_SCOPE)
endfunction (_utk_cmake_target_function_name_prefix)


function (_utk_cmake_target_git_information)
  set (_options
    ""
    )
  set (_one_value_args
    TARGET
    )
  set (_multi_value_args
    ""
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  find_package (Git)

  if (GIT_FOUND)
    exec_program (
	  "${GIT_EXECUTABLE}"
	  "${PROJECT_SOURCE_DIR}"
	  ARGS "describe --always --dirty --long --tags"
	  OUTPUT_VARIABLE _git_describe)

    exec_program (
	  "${GIT_EXECUTABLE}"
	  "${PROJECT_SOURCE_DIR}"
	  ARGS "ls-files --others --exclude-standard"
	  OUTPUT_VARIABLE _git_untracked)

    if (_git_untracked)
	  set (_git_untracked ".with-untracked")
    endif (_git_untracked)

    get_target_property (_target_type "${i_TARGET}" TYPE)

    if (_target_type STREQUAL "INTERFACE_LIBRARY")
      set (_property_name_prefix "INTERFACE_")
    endif ()

    set_target_properties (${i_TARGET}
	  PROPERTIES
	  ${_property_name_prefix}UTK_CMAKE_GIT_DESCRIBE         "${_git_describe}"
	  ${_property_name_prefix}UTK_CMAKE_GIT_UNTRACKED_FILES  "${_git_untracked}")
  endif (GIT_FOUND)
endfunction (_utk_cmake_target_git_information)


function (_utk_cmake_target_info_functions)
  set (CMAKE_DEFINE "#cmakedefine")

  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_text_arguments
    CONTRIBUTORS
    LICENSE
    LICENSE_NAME
    NOTICE
    COPYRIGHT_INFO
    )
  set (_one_value_args
    TARGET
    COMMON_TARGET_IDENTIFIER
    ${_text_arguments}
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  get_target_property (_target_type "${i_TARGET}" TYPE)

  if (_target_type STREQUAL "INTERFACE_LIBRARY")
    set (_property_name_prefix "INTERFACE_")
  endif ()

  # Gather target property values
  get_target_property (TARGET_GIT_DESCRIBE
	${i_TARGET}  ${_property_name_prefix}UTK_CMAKE_GIT_DESCRIBE)

  get_target_property (TARGET_GIT_UNTRACKED
	${i_TARGET}  ${_property_name_prefix}UTK_CMAKE_GIT_UNTRACKED_FILES)

  get_target_property (_target_include_prefix
	${i_TARGET}  ${_property_name_prefix}UTK_CMAKE_INCLUDE_PREFIX)

  get_target_property (_target_cxx_namespace
    ${i_TARGET}  ${_property_name_prefix}UTK_CMAKE_PROJECT_CXX_NAMESPACE)

  if (NOT (_target_type STREQUAL "INTERFACE_LIBRARY"))
    get_target_property (TARGET_EXPORT_HEADER
	  ${i_TARGET}  UTK_CMAKE_EXPORT_HEADER)

    get_target_property (TARGET_EXPORT_MACRO
	  ${i_TARGET}  UTK_CMAKE_EXPORT_MACRO)

    if (NOT TARGET_EXPORT_HEADER OR
        NOT TARGET_EXPORT_MACRO)
      message (SEND_ERROR "UTK_CMAKE_EXPORT_HEADER and/or UTK_CMAKE_EXPORT_MACRO property was not set.")

      return ()
    endif ()
  endif ()

  _utk_cmake_target_version (
    TARGET  "${_target}"
    VERSION _target_version
    )

  _utk_cmake_target_language (
    TARGET "${i_TARGET}"
    LANGUAGE _target_language
    )

  # Set flags and variables for code generations
  if (i_COMMON_TARGET_IDENTIFIER)
    string (MAKE_C_IDENTIFIER "${i_COMMON_TARGET_IDENTIFIER}" TARGET_IDENTIFIER)
  else ()
    string (MAKE_C_IDENTIFIER "${i_TARGET}" TARGET_IDENTIFIER)
  endif ()

  if (TARGET_GIT_DESCRIBE OR TARGET_GIT_UNTRACKED)
    set (${TARGET_IDENTIFIER}_HAS_GIT_INFO true)
  endif ()

  if (TARGET_EXPORT_HEADER AND TARGET_EXPORT_MACRO)
    set (${TARGET_IDENTIFIER}_HAS_EXPORT_HEADER true)
  endif ()

  utk_cmake_split_version_string (
    VERSION_STRING  "${_target_version}"
    OUTPUT_MAJOR    TARGET_VERSION_MAJOR
    OUTPUT_MINOR    TARGET_VERSION_MINOR
    OUTPUT_PATCH    TARGET_VERSION_PATCH
    )

  if (_target_cxx_namespace)
    _utk_cmake_format_cxx_namespace (
      NESTED_NAMESPACE_LIST  ${_target_cxx_namespace}
      NAMESPACE_BEGIN        TARGET_BEGIN_NAMESPACE
      NAMESPACE_END          TARGET_END_NAMESPACE
      )

    if (_target_language STREQUAL "CXX")
      set (${TARGET_IDENTIFIER}_USE_NAMESPACE true)
    endif ()

    if (_target_type STREQUAL "INTERFACE_LIBRARY")
      set (TARGET_FUNCTION_NAME_PREFIX  "inline ")
    endif ()
  else ()
    _utk_cmake_target_function_name_prefix (
      TARGET                    ${i_TARGET}
      COMMON_TARGET_IDENTIFIER  "${i_COMMON_TARGET_IDENTIFIER}"
      OUTPUT                    TARGET_FUNCTION_NAME_PREFIX
      )
  endif ()

  if (NOT (_target_type STREQUAL "INTERFACE_LIBRARY"))
    set (${TARGET_IDENTIFIER}_SEPARATE_INFO_FUNCTIONS_DEFINITIONS true)
  endif ()

  set (${TARGET_IDENTIFIER}_LANG_IS_${_target_language} true)

  string (MAKE_C_IDENTIFIER
    "${_target_include_prefix}/${TARGET_IDENTIFIER}.h"
    TARGET_INCLUDE_GUARD)

  string (TOUPPER "${TARGET_INCLUDE_GUARD}" TARGET_INCLUDE_GUARD)

  foreach (_argument IN LISTS _text_arguments)
    # Escape multiline text to make it look (almost) the same way as in the
    # original file
    if (i_${_argument})
      set (${TARGET_IDENTIFIER}_HAS_${_argument} true)

      set (_escaped_value ${i_${_argument}})

      # Escape \, " and %
      string (REPLACE "\\" "\\\\" _escaped_value ${_escaped_value})
      string (REPLACE "\"" "\\\"" _escaped_value ${_escaped_value})
      string (REPLACE "\%" "%%" _escaped_value ${_escaped_value})
      # Wrap each line in quotes and place "\n" at its end
      string (REGEX REPLACE
        "([^\r\n]+)(\r?\n)?"
        "\"\\1\\\\n\"\\n"
        _escaped_value ${_escaped_value})
      # Replace each empty line with "\n"
      string (REGEX REPLACE
        "(\"\r?\n)(\r?\n)(\")"
        "\\1\"\\\\n\"\\2\\3"
        _escaped_value ${_escaped_value})
      # Remove \n at the end
      string (REGEX REPLACE
        "(.*)\\\\n"
        "\\1"
        _escaped_value ${_escaped_value})

      set (TARGET_${_argument} ${_escaped_value})
    endif ()
  endforeach ()

  set (TARGET_LICENSE_NAME "${i_LICENSE_NAME}")

  # Generate files
  set (
	_header_file_template
	"${UTK_CMAKE_PRODUCT_MODULE_DIRECTORY}/utk_cmake_product/version.h.in")

  set (
	_source_file_template
	"${UTK_CMAKE_PRODUCT_MODULE_DIRECTORY}/utk_cmake_product/version.c.in")

  set (_file_base_name "${TARGET_IDENTIFIER}_version")

  # Generate intermediate files with #cmakedefine macros that based on
  # TARGET_IDENTIFIER.
  set (_header_template_stage_1
    "${PROJECT_BINARY_DIR}/${_file_base_name}.h.in")

  set (_source_template_stage_1
    "${PROJECT_BINARY_DIR}/${_file_base_name}.c.in")

  set (_declaration_file
    "${PROJECT_BINARY_DIR}/include/${_target_include_prefix}/${_file_base_name}.h")

  configure_file (
	"${_header_file_template}"
	"${_header_template_stage_1}"
    @ONLY)

  configure_file (
	"${_source_file_template}"
	"${_source_template_stage_1}"
    @ONLY)

  # Generate final output files
  if (_target_type STREQUAL "INTERFACE_LIBRARY")
    set (_sources_type "INTERFACE")
  else ()
    set (_sources_type "PRIVATE")
  endif ()

  configure_file (
	"${_header_template_stage_1}"
	"${_declaration_file}")

  target_sources ("${i_TARGET}"
    ${_sources_type}
    $<BUILD_INTERFACE:${_declaration_file}>
    $<INSTALL_INTERFACE:include/${_target_include_prefix}/${_file_base_name}.h>)

  set (_definitions_file "")

  if (("C" STREQUAL _target_language) OR
      ("UNDEFINED" STREQUAL _target_language))
    set (_definitions_file
      "${PROJECT_BINARY_DIR}/include/${_target_include_prefix}/${_file_base_name}.c")

    configure_file(
      "${_source_template_stage_1}"
      "${_definitions_file}")
  elseif ("CXX" STREQUAL _target_language)
    set (_definitions_file
      "${PROJECT_BINARY_DIR}/include/${_target_include_prefix}/${_file_base_name}.cpp")

    configure_file(
      "${_source_template_stage_1}"
      "${_definitions_file}")
  else ()
    message (SEND_ERROR "Unknown language \"${_target_language}\"")

    return ()
  endif ()

  # Add target sources and set properties
  set_target_properties (
    ${_target}
    PROPERTIES
    ${_property_name_prefix}UTK_CMAKE_PROJECT_INFO_HEADER  "${_declaration_file}"
    )

  if (_target_type STREQUAL "INTERFACE_LIBRARY")
    file (READ "${_definitions_file}" _definitions)

    file (READ "${_declaration_file}" _declarations)

    string (REPLACE
      "// UTK_CMAKE_INLINE_FUNCTION_DEFINITIONS_GO_HERE"
      "${_definitions}"
      _declarations
      "${_declarations}"
      )

    file (WRITE "${_declaration_file}" "${_declarations}")
  else ()
    target_sources ("${i_TARGET}"
      ${_sources_type}
      "${_definitions_file}")
  endif ()
endfunction (_utk_cmake_target_info_functions)


function (_utk_cmake_target_language)
  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    TARGET
    LANGUAGE
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

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
  if (_target_type STREQUAL "INTERFACE_LIBRARY")
    get_target_property (_target_language_property
	  ${i_TARGET}  INTERFACE_UTK_CMAKE_LANGUAGE)
  else ()
    get_target_property (_target_language_property
	  ${i_TARGET}  UTK_CMAKE_LANGUAGE)

    get_target_property (_c_extensions
	  ${i_TARGET}  C_EXTENSIONS)
    get_target_property (_c_standard
	  ${i_TARGET}  C_STANDARD)
    get_target_property (_cxx_extensions
	  ${i_TARGET}  CXX_EXTENSIONS)
    get_target_property (_cxx_standard
	  ${i_TARGET}  CXX_STANDARD)
    get_target_property (_linker_language
	  ${i_TARGET}  LINKER_LANGUAGE)
  endif ()

  get_property(_enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES)

  set (_target_language "UNDEFINED")

  if (_target_language_property)
    set (_target_language "${_target_language_property}")
  elseif (_linker_language)
    set (_target_language ${_linker_language})
  else ()
    if (_c_extensions OR _c_standard OR ("C" IN_LIST _enabled_languages))
      set (_target_language "C")
    endif ()

    if (_cxx_extensions OR _cxx_standard OR ("CXX" IN_LIST _enabled_languages))
      set (_target_language "CXX")
    endif ()
  endif ()

  set (${i_LANGUAGE} ${_target_language} PARENT_SCOPE)
endfunction (_utk_cmake_target_language)


function (_utk_cmake_target_version)
  set (_options
    ""
    )
  set (_multi_value_args
    ""
    )
  set (_one_value_args
    TARGET
    VERSION
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

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
  get_target_property (_target_type "${i_TARGET}" TYPE)

  if (NOT (_target_type STREQUAL "INTERFACE_LIBRARY"))
    get_target_property (_target_version ${i_TARGET} VERSION)
  endif ()

  if (NOT _target_version)
    set (_target_version ${${PROJECT_NAME}_VERSION})
  endif ()

  set (${i_VERSION} ${_target_version} PARENT_SCOPE)
endfunction (_utk_cmake_target_version)
