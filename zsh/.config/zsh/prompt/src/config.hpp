#pragma once

#include <cstdint>

namespace cfg {

namespace left_prompt {

constexpr char container_indicator_color[] = "#cc5500";
constexpr char container_indicator_text[] = "#dddddd";
constexpr char base_color[] = "#2a2a30";
constexpr char shell_level_color[] = "#cccc00";
constexpr char separator_color[] = "#777777";
constexpr char time_color[] = "#bbbb00";
constexpr char date_color[] = "#bbbb00";
constexpr char cwd_color[] = "#8888ff";
constexpr char git_color[] = "#ffbb00";
constexpr char error_color[] = "#ff2222";
constexpr char success_color[] = "#00dd00";
constexpr char cmd_separator_color[] = "#444444";
constexpr char cmd_num_color[] = "#dddddd";
constexpr char arrow_color_1[] = "#333333";
constexpr char arrow_color_2[] = "#555555";
constexpr char arrow_color_3[] = "#777777";
constexpr char sudo_enabled_indicator_bg[] = "#aa0000";
constexpr char sudo_enabled_indicator_fg[] = "#ffffff";

constexpr uint8_t min_empty_lines_bottom = 10;

} // namespace left_prompt

} // namespace cfg
