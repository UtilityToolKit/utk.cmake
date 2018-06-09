cmake_minimum_required (VERSION 3.3)


define_property (TARGET
  PROPERTY UTK_GIT_DESCRIBE
  BRIEF_DOCS "Advanced version info for developers"
  FULL_DOCS "String with information that is important for developers during
  development process. This information includes git commit hash, durty status
  of repo, distance from the last tag.")

define_property (TARGET
  PROPERTY UTK_GIT_UNTRACKED_FILES
  BRIEF_DOCS "Information about presence of untracked files"
  FULL_DOCS "Used in helper functions generation to add .with-untracked suffix
  to version string. Suffix is only added if there are some untracked not
  ignored files in repository.")


set (_UTK_PROJECT_VERSIONING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})


function (utk_target_version_information)
  set (_options
    CREATE_VERSION_INFO_FUNCTIONS
    )
  set (_required_one_value_args
	TARGET_NAME
    EXPORT_HEADER
    EXPORT_MACRO
    VERSIONED_ENTITY
    INCLUDE_PREFIX
    )
  set (_one_value_args
    ${_required_one_value_args}
    COMPANY_NAME
    COMPANY_NAME_FILE
    COMMENTS
    COMMENTS_FILE
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT DEFINED i_TARGET_NAME OR
      NOT DEFINED i_EXPORT_HEADER OR
      NOT DEFINED i_EXPORT_MACRO OR
      NOT DEFINED i_VERSIONED_ENTITY OR
      NOT DEFINED i_INCLUDE_PREFIX)
    message (
      FATAL_ERROR "One of the required arguments is not provided. Check ${_required_one_value_args}")
  endif()

  # Общие функции, выполняемые для версионирования проекта.

  # Информация о коммите.
  #
  # Необходима для идентицикации версий на этапе разработки между релизами. В
  # документации для внешнего заказчика может обозначаться, как служебная
  # информация о релизе.
  exec_program (
	"git"
	${PROJECT_SOURCE_DIR}
	ARGS "describe --always --dirty --long --tags"
	OUTPUT_VARIABLE _git_describe)

  # Информация о незафиксированных изменениях.
  #
  # В случае, если в репозитории имеются незафиксированные изменения, к строке
  # версии будет добавлено слово dirty. Это необходимо для того, чтобы была
  # возможность определить факт того, что собранная версия может включать в себя
  # какие-то изменения, которые не были зафиксированы, а значит не годится для
  # использования где-либо, кроме тестового стенда.
  #
  # При формировании значения учитываются файлы, не находящиеся под контролем
  # версий. В случае, если такие файлы присутствуют и не используются при
  # сборке, необходимо настроить их глобальное или локальное игнорирование.
  exec_program (
	"git"
	${PROJECT_SOURCE_DIR}
	ARGS "ls-files --others --exclude-standard"
	OUTPUT_VARIABLE _git_untracked)

  if (_git_untracked)
	set (_git_untracked ".with-untracked")
  endif (_git_untracked)

  set_target_properties (${i_TARGET_NAME}
	PROPERTIES
	UTK_GIT_DESCRIBE "${_git_describe}"
	UTK_GIT_UNTRACKED_FILES "${_git_untracked}")

  # Информация о версии ПО.
  #
  # Формируется в формате мажор.минор.патч в соответствии с Semantic
  # Versioning. Подробную информацию о том, как происходит присваивание версий
  # можно найти в официальном описании техники версионирования.

  if (i_CREATE_VERSION_INFO_FUNCTIONS)
    set (
	  _header_file_template
	  "${_UTK_PROJECT_VERSIONING_DIRECTORY}/utk_project_versioning/version.h.in")

    set (
	  _source_file_template
	  "${_UTK_PROJECT_VERSIONING_DIRECTORY}/utk_project_versioning/version.c.in")

    configure_file (
	  "${_header_file_template}"
	  "${PROJECT_BINARY_DIR}/${i_VERSIONED_ENTITY}_version.h")
    target_sources ("${i_TARGET_NAME}"
      PRIVATE
      $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/${i_VERSIONED_ENTITY}_version.h>
      $<INSTALL_INTERFACE:include/${i_INCLUDE_PREFIX}/${i_VERSIONED_ENTITY}_version.h>)

    get_property(_enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES)

    if ("C" IN_LIST _enabled_languages)
      configure_file(
	    "${_source_file_template}"
	    "${PROJECT_BINARY_DIR}/${i_VERSIONED_ENTITY}_version.c")

      target_sources ("${i_TARGET_NAME}"
	    PRIVATE
	    ${PROJECT_BINARY_DIR}/${i_VERSIONED_ENTITY}_version.c)
    elseif ("CXX" IN_LIST _enabled_languages)
      configure_file(
	    "${_source_file_template}"
	    "${PROJECT_BINARY_DIR}/${i_VERSIONED_ENTITY}_version.cpp")

      target_sources ("${i_TARGET_NAME}"
	    PRIVATE
	    ${PROJECT_BINARY_DIR}/${i_VERSIONED_ENTITY}_version.cpp)
    endif ("C" IN_LIST _enabled_languages)
  endif (i_CREATE_VERSION_INFO_FUNCTIONS)
endfunction (utk_target_version_information)


function (utk_generate_versioning_information)
  set (_options
    CREATE_VERSION_INFO_FUNCTIONS
    )
  set (_required_one_value_args
	TARGET_NAME
    EXPORT_HEADER
    EXPORT_MACRO
    VERSIONED_ENTITY
    INCLUDE_PREFIX
    )
  set (_one_value_args
    ${_required_one_value_args}
    COMPANY_NAME
    COMPANY_NAME_FILE
    COMMENTS
    COMMENTS_FILE
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (NOT DEFINED i_TARGET_NAME OR
      NOT DEFINED i_EXPORT_HEADER OR
      NOT DEFINED i_EXPORT_MACRO OR
      NOT DEFINED i_VERSIONED_ENTITY OR
      NOT DEFINED i_INCLUDE_PREFIX)
    message (
      FATAL_ERROR "One of the required arguments is not provided. Check ${_required_one_value_args}")
  endif()

  get_target_property(_target_type
    "${i_TARGET_NAME}" TYPE
    )

  if ((_target_type STREQUAL STATIC_LIBRARY) OR
      (_target_type STREQUAL INTERFACE_LIBRARY))
    return()
  endif()

  set (_company_name ${i_COMPANY_NAME})
  set (_comments ${i_COMMENTS})

  if (i_COMPANY_NAME_FILE)
    file (READ ${i_COMPANY_NAME_FILE} _company_name)
  endif(i_COMPANY_NAME_FILE)

  if (i_COMMENTS_FILE)
    file (READ ${i_COMMENTS_FILE} _comments)
  endif(i_COMMENTS_FILE)

  if (i_CREATE_VERSION_INFO_FUNCTIONS)
    utk_target_version_information (
      CREATE_VERSION_INFO_FUNCTIONS
      TARGET_NAME ${i_TARGET_NAME}
      EXPORT_HEADER ${i_EXPORT_HEADER}
      EXPORT_MACRO ${i_EXPORT_MACRO}
      VERSIONED_ENTITY ${i_VERSIONED_ENTITY}
      INCLUDE_PREFIX ${i_INCLUDE_PREFIX}
      )
  else ()
    utk_target_version_information (
      TARGET_NAME ${i_TARGET_NAME}
      EXPORT_HEADER ${i_EXPORT_HEADER}
      EXPORT_MACRO ${i_EXPORT_MACRO}
      VERSIONED_ENTITY ${i_VERSIONED_ENTITY}
      INCLUDE_PREFIX ${i_INCLUDE_PREFIX}
      )
  endif (i_CREATE_VERSION_INFO_FUNCTIONS)

  if (WIN32)
    include (${_UTK_PROJECT_VERSIONING_DIRECTORY}/CMakeHelpers/generate_product_version.cmake)

    get_target_property (_git_describe
	  ${i_TARGET_NAME} UTK_GIT_DESCRIBE)

    get_target_property (_git_untracked
	  ${i_TARGET_NAME} UTK_GIT_UNTRACKED_FILES)

    if (WIN32)
      set (_new_line \\r\\n)
    else()
      set (_new_line \\n)
    endif()

    string (CONCAT _comment
      "${i_COMMENTS}"
      )

    if (_git_describe OR _git_untracked)
      string (CONCAT _comment
        "${_comment}"
        ${_new_line}
        ${_new_line}
        )

      if (_git_describe)
        string (CONCAT _comment
          "${_comment}"
          ${_git_describe}
          )
      endif()

      if (_git_untracked)
        string (CONCAT _comment
          "${_comment}"
          ${_git_untracked}
          )
      endif()
    endif (_git_describe OR _git_untracked)

    generate_product_version (
	  win32VersionInfoFiles
	  NAME ${i_VERSIONED_ENTITY}
	  VERSION_MAJOR ${${i_VERSIONED_ENTITY}_VERSION_MAJOR}
	  VERSION_MINOR ${${i_VERSIONED_ENTITY}_VERSION_MINOR}
	  VERSION_PATCH ${${i_VERSIONED_ENTITY}_VERSION_PATCH}
	  COMPANY_NAME "${_company_name}"
	  COMMENTS "${_comment}")

    target_sources (${i_TARGET_NAME}
	  PRIVATE
	  ${win32VersionInfoFiles})
  endif (WIN32)
endfunction (utk_generate_versioning_information)
