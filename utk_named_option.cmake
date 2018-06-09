cmake_minimum_required (VERSION 3.1)


include (utk_list)


function (utk_named_option_index)
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
endfunction (utk_named_option_index)


function (utk_get_named_option)
  set (_multi_value_args
    OPTION_LIST
    )
  set (_one_value_args
    OPTION_NAME
    OUTPUT
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  utk_named_option_index (
    OPTION_LIST ${i_OPTION_LIST}
    OPTION_NAME "${i_OPTION_NAME}"
    OUTPUT _option_index
    )

  list (GET i_OPTION_LIST ${_option_index} _option_value)

  set (${i_OUTPUT} ${_option_value} PARENT_SCOPE)
endfunction (utk_get_named_option)


function (utk_set_named_option)
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

  utk_named_option_index (
    OPTION_LIST ${i_OPTION_LIST}
    OPTION_NAME "${i_OPTION_NAME}"
    OUTPUT _option_index
    )

  utk_list_replace_at (
    LIST  ${i_OPTION_LIST}
    INDEX ${_option_index}
    VALUE "${i_OPTION_VALUE}"
    OUTPUT _new_options
    )

  set (${i_OUTPUT} ${_new_options} PARENT_SCOPE)
endfunction (utk_set_named_option)
