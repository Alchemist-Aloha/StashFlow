#include "icon_path.h"

#include <cassert>

int main() {
  assert(app_icon_path_for_executable("/opt/StashFlow/StashFlow") ==
         "/opt/StashFlow/data/app_icon.png");
  return 0;
}
