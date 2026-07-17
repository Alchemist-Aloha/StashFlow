#include "windows_fullscreen_controller.h"

#include <sstream>
#include <string>

namespace {

constexpr LONG_PTR BorderlessStyle(LONG_PTR style) {
  return style & ~static_cast<LONG_PTR>(WS_OVERLAPPEDWINDOW);
}

constexpr LONG_PTR BorderlessExStyle(LONG_PTR style) {
  constexpr LONG_PTR kExtendedFrameStyles =
      static_cast<LONG_PTR>(WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE |
                            WS_EX_CLIENTEDGE | WS_EX_STATICEDGE);
  return style & ~kExtendedFrameStyles;
}

static_assert((BorderlessStyle(static_cast<LONG_PTR>(WS_OVERLAPPEDWINDOW)) &
               static_cast<LONG_PTR>(WS_CAPTION)) == 0,
              "Borderless fullscreen must remove the Windows title bar");

std::string Win32Error(const char* operation, DWORD error_code) {
  std::ostringstream message;
  message << operation << " failed with Win32 error " << error_code;
  return message.str();
}

bool ReadWindowLong(HWND window, int index, LONG_PTR* value,
                    std::string* error) {
  ::SetLastError(ERROR_SUCCESS);
  const LONG_PTR result = ::GetWindowLongPtr(window, index);
  const DWORD error_code = ::GetLastError();
  if (result == 0 && error_code != ERROR_SUCCESS) {
    if (error != nullptr) {
      *error = Win32Error("GetWindowLongPtr", error_code);
    }
    return false;
  }
  *value = result;
  return true;
}

bool WriteWindowLong(HWND window, int index, LONG_PTR value,
                     std::string* error) {
  ::SetLastError(ERROR_SUCCESS);
  const LONG_PTR previous = ::SetWindowLongPtr(window, index, value);
  const DWORD error_code = ::GetLastError();
  if (previous == 0 && error_code != ERROR_SUCCESS) {
    if (error != nullptr) {
      *error = Win32Error("SetWindowLongPtr", error_code);
    }
    return false;
  }
  return true;
}

}  // namespace

WindowsFullscreenController::WindowsFullscreenController(HWND window)
    : window_(window) {}

bool WindowsFullscreenController::Enter(std::string* error) {
  const WindowsFullscreenEnterAction enter_action =
      WindowsFullscreenEnterActionFor(state_);
  if (enter_action == WindowsFullscreenEnterAction::kAlreadyFullscreen) {
    return true;
  }
  if (enter_action == WindowsFullscreenEnterAction::kBlockedByRestore) {
    if (error != nullptr) {
      *error = "Cannot enter fullscreen while restoration is pending";
    }
    return false;
  }
  if (!::IsWindow(window_)) {
    if (error != nullptr) {
      *error = "Cannot enter fullscreen for an invalid window";
    }
    return false;
  }

  const bool was_maximized = ::IsZoomed(window_) != FALSE;

  WINDOWPLACEMENT placement = {};
  placement.length = sizeof(WINDOWPLACEMENT);
  if (!::GetWindowPlacement(window_, &placement)) {
    if (error != nullptr) {
      *error = Win32Error("GetWindowPlacement", ::GetLastError());
    }
    return false;
  }

  LONG_PTR style = 0;
  LONG_PTR ex_style = 0;
  if (!ReadWindowLong(window_, GWL_STYLE, &style, error) ||
      !ReadWindowLong(window_, GWL_EXSTYLE, &ex_style, error)) {
    return false;
  }

  MONITORINFO monitor = {};
  monitor.cbSize = sizeof(MONITORINFO);
  const HMONITOR monitor_handle =
      ::MonitorFromWindow(window_, MONITOR_DEFAULTTONEAREST);
  if (monitor_handle == nullptr ||
      !::GetMonitorInfo(monitor_handle, &monitor)) {
    if (error != nullptr) {
      *error = Win32Error("GetMonitorInfo", ::GetLastError());
    }
    return false;
  }

  saved_placement_ = placement;
  saved_style_ = style;
  saved_ex_style_ = ex_style;
  saved_was_maximized_ = was_maximized;
  has_saved_state_ = true;

  std::string operation_error;
  if (!WriteWindowLong(window_, GWL_STYLE, BorderlessStyle(style),
                       &operation_error)) {
    has_saved_state_ = false;
    if (error != nullptr) {
      *error = operation_error;
    }
    return false;
  }
  if (!WriteWindowLong(window_, GWL_EXSTYLE, BorderlessExStyle(ex_style),
                       &operation_error)) {
    return FailEntry(operation_error, error);
  }

  const RECT& bounds = monitor.rcMonitor;
  if (!::SetWindowPos(window_, HWND_TOP, bounds.left, bounds.top,
                      bounds.right - bounds.left, bounds.bottom - bounds.top,
                      SWP_NOOWNERZORDER | SWP_FRAMECHANGED)) {
    return FailEntry(Win32Error("SetWindowPos", ::GetLastError()), error);
  }

  state_ = WindowsFullscreenState::kFullscreen;
  return true;
}

bool WindowsFullscreenController::Exit(std::string* error) {
  if (!WindowsFullscreenNeedsRestore(state_)) {
    return true;
  }
  return RestoreSavedState(error);
}

bool WindowsFullscreenController::FailEntry(const std::string& entry_error,
                                            std::string* error) {
  std::string rollback_error;
  const bool rollback_succeeded = RestoreSavedState(&rollback_error);
  if (error != nullptr) {
    *error = entry_error;
    if (!rollback_succeeded) {
      *error += "; rollback failed: " + rollback_error;
    }
  }
  return false;
}

bool WindowsFullscreenController::RestoreSavedState(std::string* error) {
  if (!has_saved_state_) {
    state_ = WindowsFullscreenState::kWindowed;
    return true;
  }

  bool restored = true;
  std::string first_error;
  const auto record_failure = [&](const std::string& operation_error) {
    if (restored) {
      first_error = operation_error;
    }
    restored = false;
  };

  std::string operation_error;
  if (!WriteWindowLong(window_, GWL_STYLE, saved_style_, &operation_error)) {
    record_failure(operation_error);
  }
  if (!WriteWindowLong(window_, GWL_EXSTYLE, saved_ex_style_,
                       &operation_error)) {
    record_failure(operation_error);
  }
  const WindowsFullscreenRestoreAction restore_action =
      WindowsFullscreenRestoreActionFor(saved_was_maximized_);
  if (restore_action ==
      WindowsFullscreenRestoreAction::kNormalizeThenMaximize) {
    ::ShowWindow(window_, SW_RESTORE);
  }

  if (!::SetWindowPlacement(window_, &saved_placement_)) {
    record_failure(Win32Error("SetWindowPlacement", ::GetLastError()));
  }

  if (restore_action ==
      WindowsFullscreenRestoreAction::kNormalizeThenMaximize) {
    ::ShowWindow(window_, SW_MAXIMIZE);
  }

  if (!::SetWindowPos(window_, nullptr, 0, 0, 0, 0,
                      SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
                          SWP_NOOWNERZORDER | SWP_FRAMECHANGED)) {
    record_failure(Win32Error("SetWindowPos", ::GetLastError()));
  }

  LONG_PTR restored_style = 0;
  if (!ReadWindowLong(window_, GWL_STYLE, &restored_style, &operation_error)) {
    record_failure(operation_error);
  } else if (restored_style != saved_style_) {
    record_failure("Restored GWL_STYLE does not match saved style");
  }

  LONG_PTR restored_ex_style = 0;
  if (!ReadWindowLong(window_, GWL_EXSTYLE, &restored_ex_style,
                      &operation_error)) {
    record_failure(operation_error);
  } else if (restored_ex_style != saved_ex_style_) {
    record_failure("Restored GWL_EXSTYLE does not match saved style");
  }

  const bool restored_is_maximized = ::IsZoomed(window_) != FALSE;
  if (restored_is_maximized != saved_was_maximized_) {
    record_failure("Restored maximized state does not match saved state");
  }

  state_ = WindowsFullscreenStateAfterRestore(restored);
  if (restored) {
    has_saved_state_ = false;
  } else if (error != nullptr) {
    *error = first_error;
  }
  return restored;
}
