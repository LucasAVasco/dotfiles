#include "icon.hpp"
#include "../text/text.hpp"
#include <unordered_map>

namespace icon {

const auto default_icon = Icon("");
const auto fonts_icon = Icon("󰊄");
const auto icons_icon = Icon("");
const auto themes_icon = Icon("");

const std::unordered_map<std::string, const Icon> path_to_icon = {
    // Home directories
    {"~", Icon("")},
    {"~/Desktop", Icon("󰧨")},
    {"~/Documents", Icon("󰈙")},
    {"~/Downloads", Icon("")},
    {"~/Games", Icon("")},
    {"~/Music", Icon("")},
    {"~/Notes", Icon("")},
    {"~/Pictures", Icon("󰄀")},
    {"~/Public", Icon("")},
    {"~/Repositories", Icon("󰳏")},
    {"~/Sync", Icon("")},
    {"~/Templates", Icon("󱐁")},
    {"~/Videos", Icon("󰨜")},

    // Home hidden folders
    {"~/.cache", Icon("")},
    {"~/.config", Icon("")},
    {"~/.fonts", fonts_icon},
    {"~/.local/share/fonts", fonts_icon},
    {"~/.icons", icons_icon},
    {"~/.local/share/icons", icons_icon},
    {"~/.themes", themes_icon},
    {"~/.local/share/themes", themes_icon},

    // Non-home directories
    {"/", Icon("")},
    {"/var/log", Icon("")},

}; // namespace icon

const Icon &get_directory_icon(const std::string &directory) {
    const std::string &&minimized_dir =
        (directory[0] == '~') ? directory
                              : text::replace_home_by_tilde(directory);

    auto icon_iter = path_to_icon.find(minimized_dir);

    // If the folder has not a specific icon, uses the default
    if (icon_iter == path_to_icon.end()) {
        return default_icon;
    }

    return icon_iter->second;
}

} // namespace icon
