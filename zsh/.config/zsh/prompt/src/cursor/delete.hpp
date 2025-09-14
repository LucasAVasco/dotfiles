#pragma once

#include "../cli/parser.hpp"
#include "../term/info.hpp"

namespace cursor {

inline void delete_line() { term::put_escape(cli::args.terminfo_delete_line); }

inline void delete_line(uint32_t times) {
    term::repeat_escape(cli::args.terminfo_delete_line, times);
}

} // namespace cursor
