#include "windows_fullscreen_controller.h"

namespace {

std::string LastError(const char* operation) {
  const DWORD code = GetLastError();
  return std::string(operation) + " failed (Win32 " + std::to_string(code) +
         ")";
}

std::string SetStyle(HWND window, LONG_PTR style) {
  SetLastError(ERROR_SUCCESS);
  if (SetWindowLongPtr(window, GWL_STYLE, style) == 0 &&
      GetLastError() != ERROR_SUCCESS) {
    return LastError("SetWindowLongPtr");
  }
  return {};
}

}  // namespace

std::string WindowsFullscreenController::ResizeToMonitor() {
  MONITORINFO monitor = {};
  monitor.cbSize = sizeof(monitor);
  if (!GetMonitorInfo(MonitorFromWindow(window_, MONITOR_DEFAULTTONEAREST),
                      &monitor)) {
    return LastError("GetMonitorInfo");
  }
  const RECT& bounds = monitor.rcMonitor;
  if (!SetWindowPos(window_, nullptr, bounds.left, bounds.top,
                    bounds.right - bounds.left, bounds.bottom - bounds.top,
                    SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOOWNERZORDER |
                        SWP_FRAMECHANGED)) {
    return LastError("SetWindowPos(fullscreen)");
  }
  return {};
}

std::string WindowsFullscreenController::ApplyFullscreen() {
  fullscreen_ = true;
  // Clear the zoomed state without SW_RESTORE: no intermediate normal window.
  auto error = SetStyle(window_, (saved_style_ & ~(WS_OVERLAPPEDWINDOW |
                                                   WS_MAXIMIZE | WS_MINIMIZE)) |
                                     WS_POPUP);
  if (!error.empty()) return error;
  return ResizeToMonitor();
}

std::string WindowsFullscreenController::Restore() {
  fullscreen_ = false;
  auto error = SetStyle(window_, saved_style_);
  // Try every restoration step even if an earlier one fails.
  if (!SetWindowPlacement(window_, &saved_placement_) && error.empty()) {
    error = LastError("SetWindowPlacement");
  }
  if (!SetWindowPos(window_, nullptr, 0, 0, 0, 0,
                    SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE |
                        SWP_NOOWNERZORDER | SWP_FRAMECHANGED) &&
      error.empty()) {
    error = LastError("SetWindowPos(restore)");
  }
  if (error.empty() && ((IsZoomed(window_) != FALSE) !=
                        (saved_placement_.showCmd == SW_SHOWMAXIMIZED))) {
    error = "Restored maximized state does not match saved placement";
  }
  return error;
}

std::string WindowsFullscreenController::SetFullscreen(bool fullscreen) {
  if (!fullscreen) {
    if (!restore_pending_) return {};
    auto error = Restore();
    if (error.empty()) {
      restore_pending_ = false;
    } else {
      // Leave a failed exit in fullscreen when possible, matching Flutter's UI.
      const auto rollback_error = ApplyFullscreen();
      if (!rollback_error.empty()) error += "; rollback: " + rollback_error;
    }
    return error;
  }
  if (fullscreen_) return ApplyFullscreen();
  if (restore_pending_) {
    const auto error = Restore();
    if (!error.empty()) return error;
    restore_pending_ = false;
  }

  SetLastError(ERROR_SUCCESS);
  saved_style_ = GetWindowLongPtr(window_, GWL_STYLE);
  if (saved_style_ == 0 && GetLastError() != ERROR_SUCCESS) {
    return LastError("GetWindowLongPtr");
  }
  saved_placement_.length = sizeof(saved_placement_);
  if (!GetWindowPlacement(window_, &saved_placement_)) {
    return LastError("GetWindowPlacement");
  }
  restore_pending_ = true;
  auto error = ApplyFullscreen();
  if (!error.empty()) {
    const auto rollback_error = Restore();
    if (rollback_error.empty()) {
      restore_pending_ = false;
    } else {
      error += "; rollback: " + rollback_error;
    }
  }
  return error;
}
