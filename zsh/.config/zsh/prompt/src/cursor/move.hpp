#pragma once

#include "../cli/parser.hpp"
#include "../term/info.hpp"

namespace cursor {

inline void move_down() {
    term::put_escape(cli::args.terminfo_move_cursor_down);
}

inline void move_down(uint32_t times) {
    term::repeat_escape(cli::args.terminfo_move_cursor_down, times);
}

inline void move_up() { term::put_escape(cli::args.terminfo_move_cursor_up); }

inline void move_up(uint32_t times) {
    term::repeat_escape(cli::args.terminfo_move_cursor_up, times);
}

} // namespace cursor
