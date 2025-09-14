#include "cli/parser.hpp"
#include "cursor/delete.hpp"
#include "cursor/move.hpp"

int main(int argc, char *argv[]) {
    auto &args = cli::parse_args(argc, argv);

    // Delete the first 2 lines of the prompt
    uint8_t number_lines_to_move = args.cmd_lines_num + 2;

    cursor::move_up(number_lines_to_move);
    cursor::delete_line(2);

    // Goes back to the original position
    cursor::move_down(number_lines_to_move - 1);

    return 0;
}
