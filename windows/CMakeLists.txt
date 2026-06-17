# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(carby LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "carby")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
  endif()
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Define settings for the application icon.
# APPLICATION_ICON sets the icon resource used for the window titlebar.
set(APPLICATION_ICON "runner/resources/app_icon.ico")

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Enable support for an optional marker file indicating the window should be
# shown immediately once it's ready. Disabled by default so that the standard
# embedding behavior is retained until all clients have been updated.
option(FLUTTER_ENABLE_SWIFT_PACKAGE_MANAGER "Enable Swift Package Manager for Flutter plugins" OFF)

# Flutter library and tool build rules.
set(FLUTTER_LIBRARY "${FLUTTER_MANAGED_DIR}/ephemeral/flutter_windows.dll")

# System-level dependencies.
find_package(PkgConfig)

include(flutter/generated_plugins.cmake)

# Application build; see runner/CMakeLists.txt.
add_subdirectory(runner)

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugin_registrant.cmake OPTIONAL)

# === Installation ===
# Support for building with a --target install argument.
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/flutter/ephemeral/flutter_export.h"
  "${CMAKE_CURRENT_BINARY_DIR}/flutter/ephemeral/flutter_messenger.h"
  "${CMAKE_CURRENT_BINARY_DIR}/flutter/ephemeral/flutter_plugin_registrar.h"
  "${CMAKE_CURRENT_BINARY_DIR}/flutter/ephemeral/flutter_texture_registrar.h"
  DESTINATION "${CMAKE_INSTALL_PREFIX}/data/flutter_assets"
  COMPONENT Runtime)
