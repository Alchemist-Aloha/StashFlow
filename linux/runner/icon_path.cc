#include "icon_path.h"

#include <filesystem>

std::string app_icon_path_for_executable(const std::string& executable_path) {
  return (std::filesystem::path(executable_path).parent_path() / "data" /
          "app_icon.png")
      .string();
}
