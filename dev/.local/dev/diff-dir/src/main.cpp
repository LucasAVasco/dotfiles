/**
 * @file
 * @brief Lists the files that differ between two folders.
 */

#include "./cli.hpp"
#include "./diff.hpp"
#include <iostream>

int main(int argc, char *argv[]) {
    auto config = Config(argc, argv);

    auto diff = DiffDir([](const std::filesystem::path &path) {
        std::cout << path.string() << std::endl;
    });

    diff.iterate(config.folder1, config.folder2);

    return 0;
}
