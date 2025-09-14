#pragma once

#include "../cli/parser.hpp"
#include "../term/info.hpp"

namespace cursor {

inline void clear_line() { term::put_escape(cli::args.terminfo_clear_line); }

inline void clear_line(uint32_t times) {
    term::repeat_escape(cli::args.terminfo_clear_line, times);
}

} // namespace cursor
