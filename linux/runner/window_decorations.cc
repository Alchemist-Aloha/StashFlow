#include "window_decorations.h"

#include <glib.h>

#include <initializer_list>

static bool desktop_has_token(const char* current_desktop,
                              std::initializer_list<const char*> tokens) {
  if (current_desktop == nullptr) {
    return false;
  }
  g_auto(GStrv) desktops = g_strsplit(current_desktop, ":", -1);
  for (gchar** desktop = desktops; *desktop != nullptr; ++desktop) {
    for (const char* token : tokens) {
      if (g_ascii_strcasecmp(*desktop, token) == 0) {
        return true;
      }
    }
  }
  return false;
}

bool app_should_hide_window_decorations(const char* current_desktop) {
  return desktop_has_token(current_desktop, {"Hyprland", "niri"});
}

bool app_should_use_header_bar(const char* current_desktop) {
  return desktop_has_token(current_desktop, {"GNOME"});
}
