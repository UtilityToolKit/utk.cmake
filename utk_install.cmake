function (utk_install_project)
  set (_one_value_args
    # Required
    INSTALL_DEVEL
    INSTALL_RUNTIME
    PROJECT_NAME
    TARGET_NAME
    # Optional
    EXPORT_HEADER
    HEADER_MATCHING_REGEXP
    INCLUDE_PREFIX
    LIBRARY_DESTINATION
    NAMESPACE
    RUNTIME_DESTINATION
    TARGET_OUTPUT_SUFFIX
    VERSION_HEADER
    )

  cmake_parse_arguments (i
    "${_options}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

  if ((NOT i_PROJECT_NAME) OR (NOT i_TARGET_NAME))
    message (FATAL_ERROR "Missing required arguments PROJECT_NAME and TARGET_NAME.")
  endif ((NOT i_PROJECT_NAME) OR (NOT i_TARGET_NAME))

  if (NOT i_RUNTIME_DESTINATION)
    set (i_RUNTIME_DESTINATION bin)
  endif (NOT i_RUNTIME_DESTINATION)

  if (NOT i_LIBRARY_DESTINATION)
    set (i_LIBRARY_DESTINATION lib)
  endif (NOT i_LIBRARY_DESTINATION)

  if (i_INSTALL_DEVEL)
    if (NOT i_HEADER_MATCHING_REGEXP)
      set (i_HEADER_MATCHING_REGEXP "^.*$")
    endif (NOT i_HEADER_MATCHING_REGEXP)

    install (TARGETS ${i_TARGET_NAME}
      EXPORT ${i_TARGET_NAME}
      # RUNTIME DESTINATION ${i_RUNTIME_DESTINATION} COMPONENT Runtime
      INCLUDES DESTINATION include
      ARCHIVE DESTINATION lib
      COMPONENT Devel
      )

    install (DIRECTORY include/
      DESTINATION include
      COMPONENT Devel
      FILES_MATCHING
      REGEX ${i_HEADER_MATCHING_REGEXP}
      REGEX "CMakeLists\.txt" EXCLUDE
      REGEX "^.*(~+|#+).*$" EXCLUDE
      PATTERN ".*" EXCLUDE)

    if (i_VERSION_HEADER)
      install (FILES ${i_VERSION_HEADER}
        DESTINATION include/${i_INCLUDE_PREFIX}
        COMPONENT Devel)
    endif (i_VERSION_HEADER)

    if (i_EXPORT_HEADER)
      install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${i_EXPORT_HEADER}
        DESTINATION include/${i_INCLUDE_PREFIX}
        COMPONENT Devel)
    endif (i_EXPORT_HEADER)

    install(
      EXPORT ${i_TARGET_NAME}
      DESTINATION lib/cmake/${i_TARGET_NAME}
      COMPONENT Devel
      FILE "${i_TARGET_NAME}.cmake")

    include(CMakePackageConfigHelpers)

    string (TOLOWER ${i_TARGET_NAME} CMAKE_BASE_FILE_NAME)
    string (TOLOWER ${i_TARGET_OUTPUT_SUFFIX} CMAKE_FILE_OUTPUT_SUFFIX)

    write_basic_package_version_file(
      "${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}/${CMAKE_BASE_FILE_NAME}-config-version.cmake"
      VERSION ${${i_PROJECT_NAME}_VERSION}
      COMPATIBILITY SameMajorVersion
      )

    export(EXPORT ${i_TARGET_NAME}
      FILE "${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}/${CMAKE_BASE_FILE_NAME}-targets.cmake"
      )

    configure_file("cmake/cmake-target-config.cmake.in"
      "${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}/${CMAKE_BASE_FILE_NAME}-config.cmake"
      @ONLY
      )

    set(ConfigPackageLocation "lib/cmake/${i_TARGET_NAME}")
    install(EXPORT ${i_TARGET_NAME}
      FILE
      "${CMAKE_BASE_FILE_NAME}-targets.cmake"
      NAMESPACE
      "${i_NAMESPACE}"
      DESTINATION
      ${ConfigPackageLocation}
      COMPONENT Devel
      )
    install(
      FILES
      "${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}/${CMAKE_BASE_FILE_NAME}-config.cmake"
      "${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}/${CMAKE_BASE_FILE_NAME}-config-version.cmake"
      DESTINATION
      ${ConfigPackageLocation}
      COMPONENT
      Devel
      )

    set (UTK_PC_IN_CONFIGURE_PROJECT_VERSION ${${PROJECT_NAME}_VERSION})
    configure_file(
      ${CMAKE_CURRENT_SOURCE_DIR}/pkg-config/${i_PROJECT_NAME}.pc.in
      ${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}.pc
      @ONLY
      )
    unset (UTK_PC_IN_CONFIGURE_PROJECT_VERSION)

    install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${i_TARGET_NAME}.pc
      DESTINATION
      lib/pkg-config
      COMPONENT Devel
      )
  endif (i_INSTALL_DEVEL)

  if (i_INSTALL_RUNTIME)
    install (TARGETS ${i_TARGET_NAME}
      RUNTIME DESTINATION ${i_RUNTIME_DESTINATION} COMPONENT Runtime
      LIBRARY DESTINATION ${i_LIBRARY_DESTINATION} COMPONENT Runtime)
  endif (i_INSTALL_RUNTIME)
endfunction (utk_install_project)
