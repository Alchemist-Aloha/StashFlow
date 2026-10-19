#ifndef RUNNER_WINDOW_DECORATIONS_H_
#define RUNNER_WINDOW_DECORATIONS_H_

// Matches complete, case-insensitive tokens in XDG_CURRENT_DESKTOP.
bool app_should_hide_window_decorations(const char* current_desktop);

#endif  // RUNNER_WINDOW_DECORATIONS_H_
