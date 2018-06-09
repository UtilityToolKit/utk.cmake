cmake_minimum_required (VERSION 3.3)

include (utk_named_option)


function (utk_download_option_override)
  set (_multi_value_args
    OPTION_LIST
    )
  set (_one_value_args
    PACKAGE
    OPTION_NAME
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  option (UNITYBUILD_${i_PACKAGE}_OVERRIDE_${i_OPTION_NAME}
    "Enables override of the \"${i_OPTION_NAME}\" option used to fetch package sources with ExternalProject"
    OFF
    )

  if (UNITYBUILD_${i_PACKAGE}_OVERRIDE_${i_OPTION_NAME})
    utk_get_named_option (
      OPTION_LIST ${i_OPTION_LIST}
      OPTION_NAME "${i_OPTION_NAME}"
      OUTPUT _option_value)

    set (UNITYBUILD_${i_PACKAGE}_ALTERNATIVE_${i_OPTION_NAME}
      "${_option_value}"
      CACHE
      STRING
      "\"${i_OPTION_NAME}\" used to override the one provided in project configuration"
      )

    utk_set_named_option (
      OPTION_LIST ${i_OPTION_LIST}
      OPTION_NAME "${i_OPTION_NAME}"
      OPTION_VALUE "${UNITYBUILD_${i_PACKAGE}_ALTERNATIVE_${i_OPTION_NAME}}"
      OUTPUT _option_list)

    set (${i_OUTPUT} ${_option_list} PARENT_SCOPE)
  endif(UNITYBUILD_${i_PACKAGE}_OVERRIDE_${i_OPTION_NAME})
endfunction (utk_download_option_override)


function (utk_find_or_download_package)
  set (_options
    ENABLE_UNITY_BUILD_BY_DEFAULT
    )
  set (_one_value_args
    PACKAGE
    FIND_PACKAGE_EXPORTED_TARGET
    DOWNLOADED_TARGET
    IMPORTED_TARGET
    )
  set (_multi_value_args
    FIND_PACKAGE_OPTIONS
    DOWNLOAD_OPTIONS
    DOWNLOAD_OPTIONS_WITH_OVERRIDE
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  option (UNITYBUILD_${i_PACKAGE}
    "Download and build ${i_PACKAGE} (ON) or use system provided package (OFF)"
    ${i_ENABLE_UNITY_BUILD_BY_DEFAULT}
    )

  if (NOT DEFINED i_DOWNLOADED_TARGET)
    set (i_DOWNLOADED_TARGET ${i_PACKAGE})
  endif(NOT DEFINED i_DOWNLOADED_TARGET)

  if (UNITYBUILD_${i_PACKAGE})
    set (${i_IMPORTED_TARGET} ${i_DOWNLOADED_TARGET} PARENT_SCOPE)

    foreach (_overridable_option IN LISTS i_DOWNLOAD_OPTIONS_WITH_OVERRIDE)
      if ("${_overridable_option}" IN_LIST i_DOWNLOAD_OPTIONS)
        utk_download_option_override (
          PACKAGE "${i_PACKAGE}"
          OPTION_NAME "${_overridable_option}"
          OPTION_LIST ${i_DOWNLOAD_OPTIONS}
          OUTPUT i_DOWNLOAD_OPTIONS
          )
      else ("${_overridable_option}" IN_LIST i_DOWNLOAD_OPTIONS)
        message (
          SEND_ERROR
          "Impossible to override download option \"${_overridable_option}\" that is not provided")
      endif ("${_overridable_option}" IN_LIST i_DOWNLOAD_OPTIONS)
    endforeach (_overridable_option IN LISTS i_DOWNLOAD_OPTIONS_WITH_OVERRIDE)

    if (NOT TARGET ${i_DOWNLOADED_TARGET})
      include (DownloadProject/DownloadProject.cmake)

      if (CMAKE_VERSION VERSION_LESS 3.2)
        set(UPDATE_DISCONNECTED_IF_AVAILABLE "")
      else()
        set(UPDATE_DISCONNECTED_IF_AVAILABLE "UPDATE_DISCONNECTED 1")
      endif()

      download_project (
        PROJ                ${i_PACKAGE}
        ${i_DOWNLOAD_OPTIONS}
        ${UPDATE_DISCONNECTED_IF_AVAILABLE})

      add_subdirectory (
        ${${i_PACKAGE}_SOURCE_DIR}
        ${${i_PACKAGE}_BINARY_DIR})
    endif (NOT TARGET ${i_DOWNLOADED_TARGET})
  else ()
    find_package (${i_PACKAGE} ${i_VERSION} ${i_FIND_PACKAGE_OPTIONS})

    set (${i_IMPORTED_TARGET} ${i_FIND_PACKAGE_EXPORTED_TARGET} PARENT_SCOPE)
  endif ()
endfunction (utk_find_or_download_package)
