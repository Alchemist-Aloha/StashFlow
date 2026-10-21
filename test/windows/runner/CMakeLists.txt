cmake_minimum_required(VERSION 3.14)
project(windows_fullscreen_test LANGUAGES CXX)

if(NOT WIN32)
  message(FATAL_ERROR "This test needs a Windows desktop session")
endif()

enable_testing()
add_executable(windows_fullscreen_test
  "windows_fullscreen_test.cpp"
  "../../../windows/runner/windows_fullscreen_controller.cpp"
)
target_compile_features(windows_fullscreen_test PRIVATE cxx_std_17)
target_compile_definitions(windows_fullscreen_test PRIVATE NOMINMAX)
target_include_directories(windows_fullscreen_test PRIVATE
  "../../../windows/runner"
)
target_link_libraries(windows_fullscreen_test PRIVATE user32)
add_test(NAME windows_fullscreen COMMAND windows_fullscreen_test)
