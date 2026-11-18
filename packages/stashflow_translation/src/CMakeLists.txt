cmake_minimum_required(VERSION 3.22)
cmake_policy(SET CMP0091 NEW)
project(stashflow_translation LANGUAGES C CXX)
include(FetchContent)
set(CMAKE_POLICY_VERSION_MINIMUM 3.5 CACHE STRING "" FORCE)

# Build one self-contained CPU library; no Python, GPU runtime or model assets.
# CTranslate2's only GPU backend is CUDA, which is not bundled. Hardware
# acceleration here means CPU ISA dispatch on x86_64 and Accelerate on Apple.
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
# CTranslate2 derives its kernel ISA from CMAKE_SYSTEM_PROCESSOR. Enable runtime
# AVX/AVX2/AVX-512 dispatch only when that agrees with an x86_64 target, so a
# mismatched Apple cross-build never compiles x86 kernels for ARM (or the
# reverse). ARM64 already uses NEON kernels without dispatch.
if(APPLE AND CMAKE_OSX_ARCHITECTURES)
  set(sf_target_arch "${CMAKE_OSX_ARCHITECTURES}")
elseif(ANDROID)
  set(sf_target_arch "${ANDROID_ABI}")
elseif(WIN32 AND CMAKE_GENERATOR_PLATFORM)
  set(sf_target_arch "${CMAKE_GENERATOR_PLATFORM}")
else()
  set(sf_target_arch "${CMAKE_SYSTEM_PROCESSOR}")
endif()
if(sf_target_arch MATCHES "^(x86_64|x64|AMD64|amd64)$" AND
   CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64|amd64)$")
  set(ENABLE_CPU_DISPATCH ON CACHE BOOL "" FORCE)
else()
  set(ENABLE_CPU_DISPATCH OFF CACHE BOOL "" FORCE)
endif()
# Accelerate serves float32 GEMM on Apple (AMX on Apple silicon); int8 stays on
# Ruy. Our FindBLAS override avoids FindBLAS's link probes, which cannot run for
# iOS device targets.
set(WITH_ACCELERATE OFF CACHE BOOL "" FORCE)
if(APPLE)
  find_library(SF_ACCELERATE_FRAMEWORK Accelerate)
  if(SF_ACCELERATE_FRAMEWORK)
    list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
    set(WITH_ACCELERATE ON CACHE BOOL "" FORCE)
  endif()
endif()
message(STATUS "stashflow_translation: arch=${sf_target_arch} "
  "cpu_dispatch=${ENABLE_CPU_DISPATCH} accelerate=${WITH_ACCELERATE}")
set(BUILD_CLI OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
# Ruy's cpuinfo tools are unused, and their install rules lack an iOS bundle destination.
set(CPUINFO_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
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
if(CMAKE_SYSTEM_NAME STREQUAL "iOS" AND NOT COMMAND set_xcode_property)
  # SentencePiece expects ios-cmake's helper for its unused CLI tools.
  function(set_xcode_property)
  endfunction()
endif()
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
