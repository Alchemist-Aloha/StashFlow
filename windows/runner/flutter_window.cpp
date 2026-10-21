#include "flutter_window.h"

#include <flutter_windows.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
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
  fullscreen_ = std::make_unique<WindowsFullscreenController>(GetHandle());
  auto* registrar = flutter::PluginRegistrarManager::GetInstance()
                        ->GetRegistrar<flutter::PluginRegistrarWindows>(
                            FlutterDesktopEngineGetPluginRegistrar(
                                MultiViewDesktopGetEngineRef(),
                                "StashFlowFullscreen"));
  fullscreen_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "stash_app_flutter/fullscreen",
          &flutter::StandardMethodCodec::GetInstance());
  fullscreen_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        if (call.method_name() != "setFullScreen") {
          result->NotImplemented();
          return;
        }
        const auto* fullscreen = call.arguments()
                                     ? std::get_if<bool>(call.arguments())
                                     : nullptr;
        if (!fullscreen) {
          result->Error("invalid_arguments", "Expected a fullscreen boolean");
          return;
        }
        const auto error = fullscreen_->SetFullscreen(*fullscreen);
        if (error.empty()) {
          result->Success();
        } else {
          result->Error("fullscreen_error", error);
        }
      });
  MultiViewDesktopCreateMainView(GetHandle(), width, height, RegisterPlugins);
  const HWND flutter_hwnd =
      MultiViewDesktopGetFlutterHwnd(MultiViewDesktopGetMainViewId());
  if (flutter_hwnd != nullptr) {
    SetChildContent(flutter_hwnd);
  }

  return true;
}

void FlutterWindow::OnDestroy() {
  fullscreen_channel_.reset();
  fullscreen_.reset();
  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  LRESULT result = 0;
  if (fullscreen_ && fullscreen_->is_fullscreen()) {
    // Bypass window_manager's normal/maximized frame calculations only for the
    // main HWND. Its process-wide delegate must still handle other windows.
    if (message == WM_NCCALCSIZE) return 0;
    if (message == WM_NCHITTEST) return HTCLIENT;
    if (message == WM_GETMINMAXINFO) return 0;
    if (message == WM_SIZE) {
      return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
    }
    if (message == WM_SYSCOMMAND &&
        ((wparam & 0xfff0) == SC_MAXIMIZE ||
         (wparam & 0xfff0) == SC_SIZE || (wparam & 0xfff0) == SC_MOVE)) {
      return 0;
    }
    if (message == WM_DPICHANGED || message == WM_DISPLAYCHANGE) {
      // Let plugins update their DPI bookkeeping, but do not apply the normal
      // window's suggested rectangle while fullscreen.
      MultiViewDesktopHandleWindowProc(hwnd, message, wparam, lparam, &result);
      const auto error = fullscreen_->ResizeToMonitor();
      if (!error.empty()) OutputDebugStringA(error.c_str());
      return 0;
    }
  }
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
