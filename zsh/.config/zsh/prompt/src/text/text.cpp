#include <cstdint>
#include <iostream>

#include "../cli/parser.hpp"
#include "../env/env.hpp"
#include "text.hpp"

namespace text {

std::string ensure_trailing_slash(const std::string &text) {
    return (text[text.size() - 1] == '/') ? text : text + '/';
}

std::string replace_home_by_tilde(const std::string &directory) {
    if (directory[0] == '~')
        return directory;

    std::string dir_with_trailing_slash = ensure_trailing_slash(directory);

    std::string::size_type pos_end_home = 0,
                           max_pos = dir_with_trailing_slash.size();
    for (uint8_t count = 2; count > 0; --count) {
        pos_end_home = std::min(pos_end_home + 1, max_pos);
        pos_end_home = dir_with_trailing_slash.find('/', pos_end_home);
    }

    if (directory.substr(0, pos_end_home) == env::home)
        return '~' + directory.substr(pos_end_home);

    else
        return directory;
}

void insert_spaces(const uint32_t spaces) {
    for (uint32_t count = spaces; count > 0; --count) {
        std::cout << ' ';
    }
}

void right_align(const std::string &text, uint32_t offset) {
    insert_spaces(cli::args.columns - text.size() + offset);
    std::cout << text;
}

} // namespace text
