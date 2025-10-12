/**
 * @file
 * @brief Functions to parse the command line arguments.
 */

#pragma once

#include <iostream>
#include <string>

class Config {
  public:
    const char *folder1;
    const char *folder2;

    /**
     * @brief Create a new Config object and parse the command line arguments.
     *
     * @param argc Number of command line arguments.
     * @param argv Command line arguments.
     */
    Config(int argc, char *argv[]) : _argc(argc), _argv(argv) {
        switch (argc) {

        case 2: // `command -h` or `command --help`
            if (argv[1] == std::string("-h") ||
                argv[1] == std::string("--help")) {
                _show_help(0);
            } else {
                _show_help(1);
            }
            break;

        case 3: // `command folder1 folder2`
            if (argv[1] == std::string("--")) {
                _show_help(1);
            }

            // Gets the folders
            folder1 = argv[1];
            folder2 = argv[2];

            break;

        case 4: // `command -- folder1 folder2`
            if (argv[1] != std::string("--")) {
                _show_help(1);
            }

            // Gets the folders
            folder1 = argv[2];
            folder2 = argv[3];

            break;

        default:
            _show_help(1);
            break;
        }
    }

  private:
    /**
     * @brief Prints the help message and exits the program.
     *
     * @param exit_code True if the arguments are invalid, false otherwise.
     */
    inline void _show_help(int exit_code) {
        std::cout <<
            // clang-format off
            "Shows the differences between two folders.\n\n"
            << "USAGE\n\n"
            << _argv[0] << " -h | --help\n"
            "\tShows this mesage.\n\n"
            << _argv[0] << " [--] folder1 folder2\n"
            "\tShows the differences between folder1 and folder2.\n\n";

        // clang-format on

        exit(exit_code);
    }

    int _argc;
    char **_argv;
};
