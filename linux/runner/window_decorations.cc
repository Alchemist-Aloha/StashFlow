#include "window_decorations.h"

#include <glib.h>

bool app_should_hide_window_decorations(const char* current_desktop) {
  if (current_desktop == nullptr) {
    return false;
  }
  g_auto(GStrv) desktops = g_strsplit(current_desktop, ":", -1);
  for (gchar** desktop = desktops; *desktop != nullptr; ++desktop) {
    if (g_ascii_strcasecmp(*desktop, "Hyprland") == 0 ||
        g_ascii_strcasecmp(*desktop, "niri") == 0) {
      return true;
    }
  }
  return false;
}
