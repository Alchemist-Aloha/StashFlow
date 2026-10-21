#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/method_channel.h>

#include <memory>

#include "win32_window.h"
#include "windows_fullscreen_controller.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;
  std::unique_ptr<WindowsFullscreenController> fullscreen_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      fullscreen_channel_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
