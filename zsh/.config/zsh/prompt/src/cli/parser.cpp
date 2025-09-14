#include "parser.hpp"
#include <cstdint>
#include <cstring>
#include <iostream>
#include <string>
#include <unordered_map>

namespace cli {

inline bool str_empty(const char *const str) {
    return std::strcmp(str, "") == 0;
}

inline uint32_t s2uint32(const char *const str) {
    if (str_empty(str)) {
        return 0;
    }

    return std::stoul(str);
}

inline int s2int(const char *const str) {
    if (str_empty(str)) {
        return 0;
    }

    return std::stoi(str);
}

inline double s2double(const char *const str) {
    if (str_empty(str)) {
        return 0;
    }

    return std::stod(str);
}

std::unordered_map<std::string, uint32_t &> converterUint32 = {
    {"--columns", args.columns},
    {"--cmd-num", args.cmd_number},
    {"--show-cmd-separator", args.show_cmd_separator},
    {"--cmd-lines-num", args.cmd_lines_num},
};

std::unordered_map<std::string, int &> converterInt = {
    {"--last-error", args.last_cmd_error},
    {"--mv-prompt-down", args.mv_prompt_down},
};

std::unordered_map<std::string, double &> converterDouble = {
    {"--cmd-start-time", args.cmd_start_time},
    {"--time-now", args.time_now},
};

std::unordered_map<std::string, const char *&> converterString = {
    {"--terminfo-mv-cursor-up", args.terminfo_move_cursor_up},
    {"--terminfo-mv-cursor-down", args.terminfo_move_cursor_down},
    {"--terminfo-clear-line", args.terminfo_clear_line},
    {"--terminfo-delete-line", args.terminfo_delete_line},
};

const Args &parse_args(const int argc, const char *const argv[]) {
    // Uses the cached arguments
    static bool already_parsed = false;

    if (already_parsed) {
        return args;
    }
    already_parsed = true;

    // Parses the arguments
    auto arg = argv;
    for (auto i = 1; i < argc; i += 2) {
        const auto key = argv[i];
        const char *const arg = argv[i + 1];

        if (auto variable = converterUint32.find(key);
            variable != converterUint32.end()) { // Uint32 variables
            variable->second = s2uint32(arg);
        }

        else if (auto variable = converterInt.find(key);
                 variable != converterInt.end()) { // Int variables
            variable->second = s2int(arg);
        }

        else if (auto variable = converterDouble.find(key);
                 variable != converterDouble.end()) { // Double variables
            variable->second = s2double(arg);
        }

        else if (auto variable = converterString.find(key);
                 variable != converterString.end()) { // String variables
            variable->second = arg;
        }

        else {
            std::cerr << "Unknown argument: " << key << std::endl;
        }
    }

    return args;
}

}; // namespace cli
