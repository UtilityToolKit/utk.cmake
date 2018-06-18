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


cmake_minimum_required (VERSION 3.3 FATAL_ERROR)


set (UTK_CMAKE_TARGET_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

include (${UTK_CMAKE_TARGET_MODULE_DIR}/utk_cmake_target/utk_cmake_target_export.cmake)
include (${UTK_CMAKE_TARGET_MODULE_DIR}/utk_cmake_target/utk_cmake_target_library.cmake)
include (${UTK_CMAKE_TARGET_MODULE_DIR}/utk_cmake_target/utk_cmake_target_name_mangling.cmake)
include (${UTK_CMAKE_TARGET_MODULE_DIR}/utk_cmake_target/utk_cmake_target_properties.cmake)
include (${UTK_CMAKE_TARGET_MODULE_DIR}/utk_cmake_target/utk_cmake_target_qt_configuration.cmake)
