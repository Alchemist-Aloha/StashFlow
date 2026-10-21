#ifndef RUNNER_WINDOWS_FULLSCREEN_CONTROLLER_H_
#define RUNNER_WINDOWS_FULLSCREEN_CONTROLLER_H_

#include <windows.h>

#include <string>

// Owns only the main HWND. Saved placement survives failed restoration so exit
// can be retried; window_manager must not also toggle this window's fullscreen.
class WindowsFullscreenController {
 public:
  explicit WindowsFullscreenController(HWND window) : window_(window) {}

  // Empty on success; otherwise contains the failing Win32 operation and code.
  std::string SetFullscreen(bool fullscreen);
  std::string ResizeToMonitor();
  bool is_fullscreen() const { return fullscreen_; }

 private:
  std::string ApplyFullscreen();
  std::string Restore();

  HWND window_;
  bool fullscreen_ = false;
  bool restore_pending_ = false;
  LONG_PTR saved_style_ = 0;
  WINDOWPLACEMENT saved_placement_ = {};
};

#endif  // RUNNER_WINDOWS_FULLSCREEN_CONTROLLER_H_
