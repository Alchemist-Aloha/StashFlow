cmake_minimum_required(VERSION 3.22)
cmake_policy(SET CMP0091 NEW)
project(stashflow_translation LANGUAGES C CXX)
include(FetchContent)
set(CMAKE_POLICY_VERSION_MINIMUM 3.5 CACHE STRING "" FORCE)

# Build one self-contained CPU library; no Python, GPU runtime or model assets.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if(MSVC)
  # Static CTranslate2 selects /MT internally. Match it in the bridge and SPM.
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(WITH_MKL OFF CACHE BOOL "" FORCE)
set(WITH_RUY ON CACHE BOOL "" FORCE)
set(OPENMP_RUNTIME NONE CACHE STRING "" FORCE)
set(ENABLE_CPU_DISPATCH OFF CACHE BOOL "" FORCE)
set(BUILD_CLI OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(ct2
  GIT_REPOSITORY https://github.com/OpenNMT/CTranslate2.git
  GIT_TAG 617405f4b050e994e829d527da6caa0e0030afe7
  GIT_SUBMODULES third_party/cpu_features third_party/spdlog third_party/ruy
  GIT_SUBMODULES_RECURSE TRUE)
FetchContent_MakeAvailable(ct2)

if(WIN32 AND (CMAKE_GENERATOR_PLATFORM STREQUAL "ARM64" OR
              CMAKE_SYSTEM_PROCESSOR MATCHES "^(ARM64|arm64|aarch64)$"))
  # The pinned cpuinfo has no Windows ARM64 implementation. Use Ruy's existing
  # fallback rather than referencing its undefined cpuinfo_isa symbol.
  get_target_property(ruy_cpuinfo_options ruy_cpuinfo COMPILE_OPTIONS)
  list(REMOVE_ITEM ruy_cpuinfo_options "-DRUY_HAVE_CPUINFO")
  set_property(TARGET ruy_cpuinfo PROPERTY COMPILE_OPTIONS "${ruy_cpuinfo_options}")
endif()

set(SPM_ENABLE_SHARED OFF CACHE BOOL "" FORCE)
set(SPM_ENABLE_TCMALLOC OFF CACHE BOOL "" FORCE)
set(SPM_BUILD_TEST OFF CACHE BOOL "" FORCE)
FetchContent_Declare(spm
  GIT_REPOSITORY https://github.com/google/sentencepiece.git
  GIT_TAG 31646a467d2051eb904e0b45de3a73e91fe1c1e3
  GIT_SHALLOW TRUE)
FetchContent_MakeAvailable(spm)

# CTranslate2 resets PIC internally after configuring Ruy.
set_target_properties(ctranslate2 PROPERTIES POSITION_INDEPENDENT_CODE ON)
if(ANDROID)
  target_compile_options(ctranslate2 PRIVATE -include "${CMAKE_CURRENT_SOURCE_DIR}/android_compat.h")
endif()
if(ANDROID AND ANDROID_ABI STREQUAL "armeabi-v7a")
  # CT2's NEON elementwise kernels require ARM64. Keep scalar kernels on ARMv7;
  # Ruy's separately compiled matrix multiplication still uses supported NEON.
  target_compile_options(ctranslate2 PRIVATE -U__ARM_NEON -U__ARM_NEON__)
endif()
add_library(stashflow_translation SHARED translation.cc)
target_include_directories(stashflow_translation PRIVATE
  ${ct2_SOURCE_DIR}/include ${ct2_SOURCE_DIR}/third_party
  ${spm_SOURCE_DIR}/src)
target_link_libraries(stashflow_translation PRIVATE ctranslate2 sentencepiece-static)
set_target_properties(stashflow_translation PROPERTIES
  CXX_VISIBILITY_PRESET hidden VISIBILITY_INLINES_HIDDEN YES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/out")
foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
  set_target_properties(stashflow_translation PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY_${config} "${CMAKE_BINARY_DIR}/out"
    RUNTIME_OUTPUT_DIRECTORY_${config} "${CMAKE_BINARY_DIR}/out")
endforeach()
if(ANDROID)
  target_link_options(stashflow_translation PRIVATE "-Wl,-z,max-page-size=16384")
endif()
