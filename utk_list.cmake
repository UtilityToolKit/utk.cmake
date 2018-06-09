cmake_minimum_required (VERSION 3.1)


function (utk_list_replace_at)
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
endfunction (utk_list_replace_at)
