#ifndef RUNNER_WINDOWS_FULLSCREEN_STATE_H_
#define RUNNER_WINDOWS_FULLSCREEN_STATE_H_

enum class WindowsFullscreenState {
  kWindowed,
  kFullscreen,
  kRestorePending,
};

enum class WindowsFullscreenEnterAction {
  kBegin,
  kAlreadyFullscreen,
  kBlockedByRestore,
};

constexpr WindowsFullscreenEnterAction WindowsFullscreenEnterActionFor(
    WindowsFullscreenState state) {
  switch (state) {
    case WindowsFullscreenState::kWindowed:
      return WindowsFullscreenEnterAction::kBegin;
    case WindowsFullscreenState::kFullscreen:
      return WindowsFullscreenEnterAction::kAlreadyFullscreen;
    case WindowsFullscreenState::kRestorePending:
      return WindowsFullscreenEnterAction::kBlockedByRestore;
  }
  return WindowsFullscreenEnterAction::kBlockedByRestore;
}

constexpr bool WindowsFullscreenNeedsRestore(WindowsFullscreenState state) {
  return state != WindowsFullscreenState::kWindowed;
}

constexpr WindowsFullscreenState WindowsFullscreenStateAfterRestore(
    bool restored) {
  return restored ? WindowsFullscreenState::kWindowed
                  : WindowsFullscreenState::kRestorePending;
}

static_assert(WindowsFullscreenEnterActionFor(
                  WindowsFullscreenStateAfterRestore(false)) ==
                  WindowsFullscreenEnterAction::kBlockedByRestore,
              "A failed exit must block entry until restoration succeeds");
static_assert(
    WindowsFullscreenNeedsRestore(WindowsFullscreenStateAfterRestore(false)),
    "A failed exit must remain retryable");

#endif  // RUNNER_WINDOWS_FULLSCREEN_STATE_H_
