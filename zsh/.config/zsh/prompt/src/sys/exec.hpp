#pragma once

#include <cstddef>
#include <cstdio>
#include <string>
#include <tuple>

namespace sys {

inline std::tuple<std::string, int> exec(const char *command) {
    FILE *process = popen(command, "r");
    std::string res = "";
    if (process == NULL) {
        return {res, -1};
    }

    char buffer[64];
    while (fgets(buffer, 64, process) != NULL) {
        res += buffer;
    }

    int process_res = pclose(process);

    return {res, process_res};
}

} // namespace sys
