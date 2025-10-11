#include <charconv>
#include <cstdlib>
#include <cstring>
#include <iostream>

#include "cli/parser.hpp"
#include "config.hpp"
#include "cursor/clear.hpp"
#include "cursor/move.hpp"
#include "dir/working.hpp"
#include "env/env.hpp"
#include "git/info.hpp"
#include "icon/icon.hpp"
#include "shell/escapes.hpp"
#include "term/ansi/colors.hpp"
#include "term/info.hpp"
#include "text/right_ostream.hpp"
#include <chrono>
#include <format>
#include <string>

void show_main_pormpt_separator(
    term::ansi::colors::EscapeColor &next_background_color) {
    static auto separator_color_fg =
        term::ansi::colors::EscapeColor(cfg::left_prompt::separator_color);
    std::cout << separator_color_fg << icon::right_triangle_inv
              << next_background_color << icon::right_triangle;
}

int main(int argc, char *argv[]) {
    auto &args = cli::parse_args(argc, argv);

    constexpr auto base_color_fg =
        term::ansi::colors::EscapeColor(cfg::left_prompt::base_color);
    constexpr auto base_color_bg =
        term::ansi::colors::EscapeColor(cfg::left_prompt::base_color, 'b');

    // Remove last prompt if it is empty
    // (the user pressed Enter without a command) {{{
    if (args.mv_prompt_down == 1) {
        term::escape_literal::open();
        cursor::move_up(4);

        for (uint8_t i = 4; i > 0; --i) {
            cursor::clear_line();
            cursor::move_down();
        }
        term::escape_literal::close();

    } else {
        // Adds a new line before each new prompt
        std::cout << std::endl;
    }

    // }}}

    // Separator between commands {{{
    if (args.show_cmd_separator > 0) {
        std::cout << std::endl << OPEN_ESCAPE;

        uint32_t num_balls_to_fill = args.columns;

        // Last command's exit status (error or success indicator)
        std::cout << term::ansi::style::italic << term::ansi::style::bold;
        if (args.last_cmd_error == 0) {
            std::cout << term::ansi::colors::EscapeColor(
                             cfg::left_prompt::success_color)
                      << " ";
        } else {
            std::cout << term::ansi::colors::EscapeColor(
                             cfg::left_prompt::error_color)
                      << " ";
        }

        num_balls_to_fill -= 2;

        // Last command's exit status (error code number)
        char error_code_str[12]; // Holds a signed 32 bits integer
        auto conversion_res = std::to_chars(error_code_str, error_code_str + 12,
                                            args.last_cmd_error);
        *conversion_res.ptr = '\0'; // Needs to manually terminate the string
                                    // (`std::to_chars` does not do it)

        std::cout << error_code_str << term::ansi::style::normal << ' '
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::cmd_separator_color);

        num_balls_to_fill -= std::strlen(error_code_str) + 1;

        // Elapsed time
        term::repeat_escape("", 5);

        auto elapsed_time = args.time_now - args.cmd_start_time;
        std::string elapsed_time_str = std::to_string(elapsed_time);
        std::cout << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::time_color)
                  << " 󱦟 " << elapsed_time_str << "s "
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::cmd_separator_color);

        num_balls_to_fill -= elapsed_time_str.length() + 5 + 5;

        // Fills with balls
        for (uint32_t count = num_balls_to_fill; count != 0; --count) {
            std::cout << "";
        }

        std::cout << CLOSE_ESCAPE << std::endl;
    }

    // }}}

    // First prompt line (right aligned) {{{

    // Date and time
    auto now = std::chrono::zoned_time{std::chrono::current_zone(),
                                       std::chrono::system_clock::now()};
    auto now_str = std::format("{0:%F} {0:%R}", now);

    text::right_cout << term::ansi::colors::EscapeColor(
                            cfg::left_prompt::date_color)
                     << icon::Icon("") << ' ' << now_str << "     ";

    // Current directory
    auto current_dir = dir::get_current_directory(false, true);

    text::right_cout << term::ansi::colors::EscapeColor(
                            cfg::left_prompt::cwd_color)
                     << icon::Icon("") << ' ' << current_dir << std::endl;

    // }}}

    // Second prompt line (main prompt) {{{

    // Shell level
    std::cout << base_color_fg << icon::left_semicircle << base_color_bg
              << term::ansi::colors::EscapeColor(
                     cfg::left_prompt::shell_level_color)
              << icon::Icon("") << ' ' << env::shlvl << ' ';

    // User name
    std::cout << env::user_name << ' ';

    // Git info
    if (auto git_info = git::GitInfo();
        git_info.get_repository_root().has_value()) {
        std::cout << term::ansi::colors::EscapeColor(
            cfg::left_prompt::git_color);

        if (git_info.get_git_user().has_value())
            std::cout << icon::Icon("") << ' '
                      << git_info.get_git_user().value() << ' ';

        if (auto branch = git_info.get_branch(); branch.has_value())
            std::cout << icon::Icon("") << ' ' << branch.value() << ' ';
    }

    // Current working directory
    auto cwd_color_bg =
        term::ansi::colors::EscapeColor(cfg::left_prompt::cwd_color, 'b');
    show_main_pormpt_separator(cwd_color_bg);
    std::string cwd = dir::get_current_directory(true, true);
    std::cout
        << base_color_fg
        << term::ansi::colors::ModEscape(term::ansi::colors::modifier::bold)
        << ' ' << icon::get_directory_icon(env::pwd) << ' ' << cwd
        << term::ansi::colors::EscapeColor(cfg::left_prompt::cwd_color)
        << term::ansi::colors::reset_bg << icon::right_semicircle
        << term::ansi::colors::ModEscape(term::ansi::colors::modifier::normal);

    // }}}

    // User input line {{{

    std::cout << std::endl << std::endl;

    // Inside container indicator
    if (std::strcmp(env::running_inside_container, "y") == 0) {
        std::cout << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::container_indicator_color)
                  << icon::left_semicircle
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::container_indicator_color, 'b')
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::container_indicator_text)
                  << term::ansi::style::bold << icon::Icon("")
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::container_indicator_color)
                  << term::ansi::colors::reset_bg
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::container_indicator_color)
                  << icon::right_semicircle << ' ';
    }

    // Sudo enabled indicator
    int res_code = std::system("sudo -n true 2> /dev/null");
    if (res_code == 0) {
        std::cout << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::sudo_enabled_indicator_bg)
                  << icon::left_semicircle
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::sudo_enabled_indicator_bg, 'b')
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::sudo_enabled_indicator_fg)
                  << term::ansi::style::bold << ' ' << icon::Icon("󰒃")
                  << " ROOT "
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::sudo_enabled_indicator_bg)
                  << term::ansi::colors::reset_bg
                  << term::ansi::colors::EscapeColor(
                         cfg::left_prompt::sudo_enabled_indicator_bg)
                  << icon::right_semicircle << ' ';
    }

    // Command number
    auto arrow_1_fg =
        term::ansi::colors::EscapeColor(cfg::left_prompt::arrow_color_1);
    std::cout
        << arrow_1_fg << icon::left_semicircle
        << term::ansi::colors::EscapeColor(cfg::left_prompt::arrow_color_1, 'b')
        << term::ansi::colors::EscapeColor(cfg::left_prompt::cmd_num_color)
        << args.cmd_number << arrow_1_fg << term::ansi::colors::reset_bg
        << term::ansi::colors::EscapeColor(cfg::left_prompt::arrow_color_1)
        << icon::right_triangle;

    // Arrows
    std::cout << term::ansi::colors::EscapeColor(
                     cfg::left_prompt::arrow_color_2)
              << icon::right_triangle_inv << icon::right_triangle;
    std::cout << term::ansi::colors::EscapeColor(
                     cfg::left_prompt::arrow_color_3)
              << icon::right_triangle_inv << icon::right_triangle;

    std::cout << "  ";

    // }}}

    return 0;
}
