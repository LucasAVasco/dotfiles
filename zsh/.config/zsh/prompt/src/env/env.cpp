#include "env.hpp"

#include <cstdlib>

namespace env {

char empty_string[] = " ";

inline char *get_env(const char *name) {
    char *user_name = std::getenv(name);

    if (user_name == nullptr) {
        return empty_string;
    }

    return user_name;
}

const char *user_name = get_env("USER");
const char *home = get_env("HOME");
const char *pwd = get_env("PWD");
const char *shlvl = get_env("SHLVL");
const char *running_inside_container = get_env("RUNNING_INSIDE_CONTAINER");

} // namespace env
