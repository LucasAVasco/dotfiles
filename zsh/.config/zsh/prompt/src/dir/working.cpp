#include "working.hpp"
#include "../env/env.hpp"

#include <filesystem>
#include <string>

namespace dir {

std::string get_current_directory(bool simplify, bool compact_tilde) {
    std::string res = "";

    std::filesystem::path cwd = env::pwd;
    std::filesystem::path::iterator begin =
        std::next(cwd.begin()); // Jumps the root directory "/"
    std::filesystem::path::iterator end = cwd.end();

    if (begin == end) {
        return "/";
    }

    if (compact_tilde) {
        std::string user_home[2];
        uint8_t sub_path_index = 0;

        for (auto sub_path_iter = begin; sub_path_iter != end;
             ++sub_path_iter) {
            std::filesystem::path sub_path = *sub_path_iter;
            if (sub_path_index == 1) {
                user_home[sub_path_index] = sub_path;

                // If the folder is inside "/home/<user_name>"
                if (user_home[0] == "home" && user_home[1] == env::user_name) {
                    res = "~";

                    // The user home is already at `res`. No need to add it
                    // anymore
                    begin = std::next(sub_path_iter);
                }

                break;

            } else {
                user_home[sub_path_index] = sub_path;
            }

            ++sub_path_index;
        }
    }

    // Append the current directory to the result (will not simplify it)
    std::string append_to_res = "";
    if (begin != end) {
        append_to_res = '/' + cwd.filename().string();
        end = std::prev(end);
    }

    // Add the missing sub-directories to the result
    for (auto sub_path_iter = begin; sub_path_iter != end; ++sub_path_iter) {
        const char *sub_path_string = (*sub_path_iter).c_str();
        res += '/';

        if (simplify) {
            char simplified_sub_path[] = "123";

            {
                uint8_t index = 0, char_to_add = sub_path_string[index];
                simplified_sub_path[index] = char_to_add;

                // shows the next character after a dot
                if (char_to_add == '.') {
                    char_to_add = sub_path_string[++index];
                    simplified_sub_path[index] = char_to_add;
                }

                // Non-ASCII characters.
                // WARN(LucasAVasco): This does not support all Non-ASCII
                // characters, only the ones that I usually use
                if (char_to_add > 128) {
                    char_to_add = sub_path_string[++index];
                    simplified_sub_path[index] = char_to_add;
                }

                simplified_sub_path[++index] = '\0';
            }

            res += simplified_sub_path;
        } else {
            res += sub_path_string;
        }
    }

    return res + append_to_res;
}

} // namespace dir
