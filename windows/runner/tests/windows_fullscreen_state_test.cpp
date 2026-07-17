#include "windows_fullscreen_state.h"

#include <cassert>

int main() {
  using State = WindowsFullscreenState;
  using EnterAction = WindowsFullscreenEnterAction;

  assert(WindowsFullscreenEnterActionFor(State::kWindowed) ==
         EnterAction::kBegin);
  assert(WindowsFullscreenEnterActionFor(State::kFullscreen) ==
         EnterAction::kAlreadyFullscreen);
  assert(WindowsFullscreenEnterActionFor(State::kRestorePending) ==
         EnterAction::kBlockedByRestore);

  assert(!WindowsFullscreenNeedsRestore(State::kWindowed));
  assert(WindowsFullscreenNeedsRestore(State::kFullscreen));
  assert(WindowsFullscreenNeedsRestore(State::kRestorePending));

  const State failed_exit = WindowsFullscreenStateAfterRestore(false);
  assert(failed_exit == State::kRestorePending);
  assert(WindowsFullscreenEnterActionFor(failed_exit) ==
         EnterAction::kBlockedByRestore);
  assert(WindowsFullscreenNeedsRestore(failed_exit));

  const State retried_exit = WindowsFullscreenStateAfterRestore(true);
  assert(retried_exit == State::kWindowed);
  assert(WindowsFullscreenEnterActionFor(retried_exit) == EnterAction::kBegin);

  return 0;
}
