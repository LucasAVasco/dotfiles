#pragma once

#include <string>

namespace dir {

std::string get_current_directory(bool simplify = false,
                                  bool compact_tilde = false);

}
