function (utk_mangling_suffix)
  set (_options
    VERSION_MANGLING
    )

  set (_one_value_args
    # Required
    OUTPUT_VARIABLE
    # Optional
    PROJECT_VERSION
    ADDITIONAL_SUFFIX
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if (i_VERSION_MANGLING AND (NOT DEFINED i_PROJECT_VERSION))
    message (FATAL_ERROR
      "PROJECT_VERSION required by VERSION_MANGLING is not provided.")
  endif (i_VERSION_MANGLING AND (NOT DEFINED i_PROJECT_VERSION))

  if (MSVC)
    set (
      _mangling_suffix
      "${_mangling_suffix}-${CMAKE_VS_PLATFORM_TOOLSET}-mt")
  endif (MSVC)

  if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set (_mangling_suffix
      "${_mangling_suffix}-x64")
  elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)
    set (_mangling_suffix
      "${_mangling_suffix}-x32")
  endif ()

  if (i_VERSION_MANGLING)
    set (
      _mangling_suffix
      "${_mangling_suffix}-${i_PROJECT_VERSION}")
  endif (i_VERSION_MANGLING)

  set (
    _mangling_suffix
    "${_mangling_suffix}${i_ADDITIONAL_SUFFIX}")

  set (${i_OUTPUT_VARIABLE} ${_mangling_suffix} PARENT_SCOPE)
endfunction (utk_mangling_suffix)
