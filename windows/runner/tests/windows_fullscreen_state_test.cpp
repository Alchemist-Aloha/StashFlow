#include "windows_fullscreen_state.h"

#include <cstdio>

namespace {

int Check(bool condition, const char* message) {
  if (condition) {
    return 0;
  }
  std::fputs(message, stderr);
  std::fputc('\n', stderr);
  return 1;
}

}  // namespace

int main() {
  using State = WindowsFullscreenState;
  using EnterAction = WindowsFullscreenEnterAction;
  using RestoreAction = WindowsFullscreenRestoreAction;

  int failures = 0;
  failures += Check(
      WindowsFullscreenRestoreActionFor(false) ==
          RestoreAction::kRestorePlacement,
      "A normal source window must restore its saved placement directly");
  failures += Check(
      WindowsFullscreenRestoreActionFor(true) ==
          RestoreAction::kNormalizeThenMaximize,
      "A maximized source window must normalize before maximizing again");

  failures += Check(
      WindowsFullscreenEnterActionFor(State::kWindowed) == EnterAction::kBegin,
      "Windowed state must begin entry");
  failures += Check(WindowsFullscreenEnterActionFor(State::kFullscreen) ==
                        EnterAction::kAlreadyFullscreen,
                    "Fullscreen state must make entry idempotent");
  failures += Check(WindowsFullscreenEnterActionFor(State::kRestorePending) ==
                        EnterAction::kBlockedByRestore,
                    "Pending restoration must block entry");

  failures += Check(!WindowsFullscreenNeedsRestore(State::kWindowed),
                    "Windowed state must not restore");
  failures += Check(WindowsFullscreenNeedsRestore(State::kFullscreen),
                    "Fullscreen state must restore");
  failures += Check(WindowsFullscreenNeedsRestore(State::kRestorePending),
                    "Pending restoration must remain retryable");

  const State failed_exit = WindowsFullscreenStateAfterRestore(false);
  failures += Check(failed_exit == State::kRestorePending,
                    "Failed exit must remain pending");
  failures += Check(WindowsFullscreenEnterActionFor(failed_exit) ==
                        EnterAction::kBlockedByRestore,
                    "Failed exit must block a new entry");
  failures += Check(WindowsFullscreenNeedsRestore(failed_exit),
                    "Failed exit must permit an exit retry");

  const State retried_exit = WindowsFullscreenStateAfterRestore(true);
  failures += Check(retried_exit == State::kWindowed,
                    "Successful retry must return to windowed");
  failures += Check(
      WindowsFullscreenEnterActionFor(retried_exit) == EnterAction::kBegin,
      "Successful retry must allow a later entry");

  return failures == 0 ? 0 : 1;
}
