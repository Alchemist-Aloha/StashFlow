#ifndef RUNNER_WINDOWS_FULLSCREEN_CONTROLLER_H_
#define RUNNER_WINDOWS_FULLSCREEN_CONTROLLER_H_

#include <windows.h>

#include <string>

#include "windows_fullscreen_state.h"

class WindowsFullscreenController {
 public:
  explicit WindowsFullscreenController(HWND window);

  bool Enter(std::string* error);
  bool Exit(std::string* error);

 private:
  bool RestoreSavedState(std::string* error);
  bool FailEntry(const std::string& entry_error, std::string* error);

  HWND window_;
  WINDOWPLACEMENT saved_placement_ = {};
  LONG_PTR saved_style_ = 0;
  LONG_PTR saved_ex_style_ = 0;
  bool saved_was_maximized_ = false;
  bool has_saved_state_ = false;
  WindowsFullscreenState state_ = WindowsFullscreenState::kWindowed;
};

#endif  // RUNNER_WINDOWS_FULLSCREEN_CONTROLLER_H_
