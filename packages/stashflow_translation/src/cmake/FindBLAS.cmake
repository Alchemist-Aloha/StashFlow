# Apple-only override used when CTranslate2 is built WITH_ACCELERATE.
# Accelerate ships in every Apple SDK; resolve it with find_library (already
# done by the parent CMakeLists) instead of FindBLAS's executable link checks.
if(NOT SF_ACCELERATE_FRAMEWORK)
  find_library(SF_ACCELERATE_FRAMEWORK Accelerate)
endif()
if(SF_ACCELERATE_FRAMEWORK)
  set(BLAS_FOUND TRUE)
  set(BLAS_LIBRARIES "${SF_ACCELERATE_FRAMEWORK}")
else()
  set(BLAS_FOUND FALSE)
  if(BLAS_FIND_REQUIRED)
    message(FATAL_ERROR "Accelerate framework not found")
  endif()
endif()
