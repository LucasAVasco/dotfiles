#pragma once

#include <cstdint>
#include <string>

namespace text {

std::string ensure_trailing_slash(const std::string &text);
std::string replace_home_by_tilde(const std::string &directory);

void insert_spaces(const uint32_t spaces);
void right_align(const std::string &text, uint32_t offset);

} // namespace text
