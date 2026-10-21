#include <cstdlib>
#include <iostream>
#include <vector>

#include "windows_fullscreen_controller.h"

#define CHECK(condition)                                           \
  do {                                                             \
    if (!(condition)) {                                            \
      std::cerr << "Line " << __LINE__ << ": " #condition << '\n'; \
      std::exit(1);                                                \
    }                                                              \
  } while (false)

namespace {

WindowsFullscreenController* controller = nullptr;

LRESULT CALLBACK WindowProc(HWND window, UINT message, WPARAM wparam,
                            LPARAM lparam) {
  // Mirror the runner's frame override, before plugin/default processing.
  if (controller && controller->is_fullscreen() && message == WM_NCCALCSIZE) {
    return 0;
  }
  return DefWindowProc(window, message, wparam, lparam);
}

BOOL CALLBACK CollectMonitors(HMONITOR monitor, HDC, LPRECT, LPARAM data) {
  reinterpret_cast<std::vector<HMONITOR>*>(data)->push_back(monitor);
  return TRUE;
}

void CheckTransitions(HWND window, bool maximized) {
  ShowWindow(window, maximized ? SW_MAXIMIZE : SW_RESTORE);
  WINDOWPLACEMENT before = {};
  before.length = sizeof(before);
  CHECK(GetWindowPlacement(window, &before));
  const auto style = GetWindowLongPtr(window, GWL_STYLE);
  const auto monitor = MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  MONITORINFO info = {};
  info.cbSize = sizeof(info);
  CHECK(GetMonitorInfo(monitor, &info));

  for (int repeat = 0; repeat < 3; ++repeat) {
    CHECK(controller->SetFullscreen(true).empty());
    CHECK(controller->SetFullscreen(true).empty());
    CHECK(controller->is_fullscreen());
    CHECK(!IsZoomed(window));
    CHECK(!(GetWindowLongPtr(window, GWL_STYLE) & WS_OVERLAPPEDWINDOW));
    CHECK(!(GetWindowLongPtr(window, GWL_EXSTYLE) & WS_EX_TOPMOST));
    RECT bounds = {};
    CHECK(GetWindowRect(window, &bounds));
    CHECK(EqualRect(&bounds, &info.rcMonitor));
    RECT client = {};
    CHECK(GetClientRect(window, &client));
    CHECK(client.right == bounds.right - bounds.left);
    CHECK(client.bottom == bounds.bottom - bounds.top);

    CHECK(controller->SetFullscreen(false).empty());
    CHECK(controller->SetFullscreen(false).empty());
    CHECK(!controller->is_fullscreen());
    CHECK((IsZoomed(window) != FALSE) == maximized);
    CHECK(GetWindowLongPtr(window, GWL_STYLE) == style);
    CHECK(MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST) == monitor);
    WINDOWPLACEMENT after = {};
    after.length = sizeof(after);
    CHECK(GetWindowPlacement(window, &after));
    CHECK(after.showCmd == before.showCmd);
    CHECK(EqualRect(&after.rcNormalPosition, &before.rcNormalPosition));
  }
}

}  // namespace

int main() {
  SetProcessDPIAware();
  WNDCLASSW window_class = {};
  window_class.lpfnWndProc = WindowProc;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.lpszClassName = L"StashFlowFullscreenTest";
  CHECK(RegisterClassW(&window_class));
  HWND window = CreateWindowW(window_class.lpszClassName, L"Fullscreen test",
                              WS_OVERLAPPEDWINDOW, 100, 100, 800, 600, nullptr,
                              nullptr, window_class.hInstance, nullptr);
  CHECK(window);
  WindowsFullscreenController fullscreen(window);
  controller = &fullscreen;
  CHECK(fullscreen.SetFullscreen(false).empty());

  std::vector<HMONITOR> monitors;
  CHECK(EnumDisplayMonitors(nullptr, nullptr, CollectMonitors,
                            reinterpret_cast<LPARAM>(&monitors)));
  for (const auto monitor : monitors) {
    MONITORINFO info = {};
    info.cbSize = sizeof(info);
    CHECK(GetMonitorInfo(monitor, &info));
    ShowWindow(window, SW_RESTORE);
    CHECK(SetWindowPos(window, nullptr, info.rcWork.left + 20,
                       info.rcWork.top + 20, 800, 600, SWP_NOZORDER));
    CheckTransitions(window, false);
    CheckTransitions(window, true);
  }

  CHECK(fullscreen.SetFullscreen(true).empty());
  CHECK(DestroyWindow(window));
  CHECK(!fullscreen.SetFullscreen(false).empty());
  CHECK(!fullscreen.SetFullscreen(false).empty());
  controller = nullptr;
  WindowsFullscreenController invalid(nullptr);
  CHECK(!invalid.SetFullscreen(true).empty());
  std::cout << "Fullscreen transitions passed on " << monitors.size()
            << " monitor(s)\n";
  return 0;
}
