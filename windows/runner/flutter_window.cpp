#include "flutter_window.h"

#include <flutter_windows.h>
#include <multiview_desktop/multi_view_desktop_plugin.h>

#include "flutter/generated_plugin_registrant.h"

namespace {

// Mirrors kDesktopMinimumWindowSize in lib/core/utils/pip_mode.dart.
constexpr double kMainWindowMinimumWidth = 800;
constexpr double kMainWindowMinimumHeight = 600;

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();
  const int width = frame.right - frame.left;
  const int height = frame.bottom - frame.top;

  MultiViewDesktopPrepareEngine(project_, GetHandle());
  MultiViewDesktopCreateMainView(GetHandle(), width, height, RegisterPlugins);
  const HWND flutter_hwnd =
      MultiViewDesktopGetFlutterHwnd(MultiViewDesktopGetMainViewId());
  if (flutter_hwnd != nullptr) {
    SetChildContent(flutter_hwnd);
  }

  return true;
}

void FlutterWindow::OnDestroy() {
  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  LRESULT result = 0;
  if (message == WM_FONTCHANGE) {
    FlutterDesktopEngineReloadSystemFonts(MultiViewDesktopGetEngineRef());
  }
  // window_manager registers a single process-wide top-level window proc
  // delegate, so a minimum size set through it also constrains
  // multiview_desktop's secondary windows such as the desktop PiP window.
  // Enforce the main window's minimum here, where it can only affect the main
  // window, and leave the PiP window free to follow the video's aspect ratio.
  if (message == WM_GETMINMAXINFO) {
    const double scale =
        FlutterDesktopGetDpiForMonitor(
            MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST)) /
        96.0;
    auto* info = reinterpret_cast<MINMAXINFO*>(lparam);
    info->ptMinTrackSize.x =
        static_cast<LONG>(kMainWindowMinimumWidth * scale);
    info->ptMinTrackSize.y =
        static_cast<LONG>(kMainWindowMinimumHeight * scale);
  }
  if (MultiViewDesktopHandleWindowProc(hwnd, message, wparam, lparam, &result)) {
    return result;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
