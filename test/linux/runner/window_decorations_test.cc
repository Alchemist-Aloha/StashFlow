#include "window_decorations.h"

#include <cassert>
#include <initializer_list>

int main() {
  for (const char* desktop :
       {"Hyprland", "hyprland", "HYPRLAND", "niri", "Niri",
        "other:Hyprland", "niri:other", ":Hyprland:"}) {
    assert(app_should_hide_window_decorations(desktop));
  }
  for (const char* desktop :
       {"", "GNOME", "KDE", "sway", "GNOME:GNOME-Classic",
        "not-Hyprland", "niri-other"}) {
    assert(!app_should_hide_window_decorations(desktop));
  }
  assert(!app_should_hide_window_decorations(nullptr));
  return 0;
}
