#pragma once

#include <cstdint>

namespace cli {

struct Args {
    uint32_t columns = 0;    //! Number of columns of the terminal.
    uint32_t cmd_number = 0; //! Number of commands that the user typed.

    //! Error code of the last command. (zero means no error)
    int last_cmd_error = 0;

    double cmd_start_time = 0; //! Command start time (seconds).
    double time_now = 0;       //! Current time (seconds).

    //! If 1, show a separator between commands.
    uint32_t show_cmd_separator = 0;

    //! Number of lines of the command that the user typed.
    uint32_t cmd_lines_num = 0;

    //! If 1, should move the prompt down (delete the last prompt)
    int mv_prompt_down = 0;

    // Term info capabilities
    const char *terminfo_move_cursor_up = nullptr;
    const char *terminfo_move_cursor_down = nullptr;
    const char *terminfo_clear_line = nullptr;
    const char *terminfo_delete_line = nullptr;
};

inline Args args;

const Args &parse_args(const int argc, const char *const argv[]);

} // namespace cli
