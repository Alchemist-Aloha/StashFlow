cmake_minimum_required(VERSION 3.21)
project(avif_native C)

set(AVIF_PROFILE "full-aom-aom" CACHE STRING "Native codec profile")
set(LIBAVIF_SOURCE_DIR "" CACHE PATH "Path to libavif sources")
if(NOT EXISTS "${LIBAVIF_SOURCE_DIR}/CMakeLists.txt")
  message(FATAL_ERROR "Set LIBAVIF_SOURCE_DIR to a libavif checkout")
endif()

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if(MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(AVIF_BUILD_APPS OFF CACHE BOOL "" FORCE)
set(AVIF_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(AVIF_LIBYUV OFF CACHE STRING "" FORCE)
set(AVIF_ZLIBPNG OFF CACHE BOOL "" FORCE)
set(AVIF_JPEG OFF CACHE BOOL "" FORCE)

if(AVIF_PROFILE STREQUAL "decode-dav1d")
  set(AVIF_CODEC_AOM OFF CACHE STRING "" FORCE)
  set(AVIF_CODEC_DAV1D LOCAL CACHE STRING "" FORCE)
  set(HAS_DECODE 1)
  set(HAS_ENCODE 0)
elseif(AVIF_PROFILE STREQUAL "encode-aom")
  set(AVIF_CODEC_AOM LOCAL CACHE STRING "" FORCE)
  set(AVIF_CODEC_AOM_DECODE OFF CACHE BOOL "" FORCE)
  set(AVIF_CODEC_AOM_ENCODE ON CACHE BOOL "" FORCE)
  set(AVIF_CODEC_DAV1D OFF CACHE STRING "" FORCE)
  set(HAS_DECODE 0)
  set(HAS_ENCODE 1)
elseif(AVIF_PROFILE STREQUAL "full-aom-aom")
  set(AVIF_CODEC_AOM LOCAL CACHE STRING "" FORCE)
  set(AVIF_CODEC_AOM_DECODE ON CACHE BOOL "" FORCE)
  set(AVIF_CODEC_AOM_ENCODE ON CACHE BOOL "" FORCE)
  set(AVIF_CODEC_DAV1D OFF CACHE STRING "" FORCE)
  set(HAS_DECODE 1)
  set(HAS_ENCODE 1)
elseif(AVIF_PROFILE STREQUAL "full-dav1d-aom")
  set(AVIF_CODEC_AOM LOCAL CACHE STRING "" FORCE)
  set(AVIF_CODEC_AOM_DECODE OFF CACHE BOOL "" FORCE)
  set(AVIF_CODEC_AOM_ENCODE ON CACHE BOOL "" FORCE)
  set(AVIF_CODEC_DAV1D LOCAL CACHE STRING "" FORCE)
  set(HAS_DECODE 1)
  set(HAS_ENCODE 1)
else()
  message(FATAL_ERROR "Unknown AVIF_PROFILE: ${AVIF_PROFILE}")
endif()

add_subdirectory("${LIBAVIF_SOURCE_DIR}" libavif-build EXCLUDE_FROM_ALL)

add_library(avif_native SHARED ../src/avif_shim.c)
target_link_libraries(avif_native PRIVATE avif)
target_compile_definitions(avif_native PRIVATE
  AVIF_NATIVE_HAS_DECODE=${HAS_DECODE}
  AVIF_NATIVE_HAS_ENCODE=${HAS_ENCODE}
)
set_target_properties(avif_native PROPERTIES
  C_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN YES
  OUTPUT_NAME avif_native
)

if(APPLE)
  set_target_properties(avif_native PROPERTIES
    BUILD_WITH_INSTALL_RPATH YES
    INSTALL_NAME_DIR "@rpath"
  )
  target_link_options(avif_native PRIVATE
    "LINKER:-dead_strip"
    "LINKER:-headerpad_max_install_names"
  )
elseif(UNIX AND NOT ANDROID)
  target_link_options(avif_native PRIVATE "LINKER:--gc-sections")
endif()

if(CMAKE_C_COMPILER_ID MATCHES "AppleClang|Clang")
  target_compile_options(avif_native PRIVATE -Oz -ffunction-sections -fdata-sections)
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(avif_native PRIVATE -Os -ffunction-sections -fdata-sections)
elseif(MSVC)
  target_compile_options(avif_native PRIVATE /O1)
endif()
