/**
 * @file
 * @brief Functions to check if two files are equal.
 */

#pragma once

#include <cstring>
#include <filesystem>
#include <fstream>

/**
 * @brief Check if two files have the same size.
 *
 * @param file1 First file.
 * @param file2 Second file.
 * @return True if the files have the same size, false otherwise.
 */
inline bool files_have_same_size(const std::filesystem::path &file1,
                                 const std::filesystem::path &file2) {
    std::error_code error_code;

    auto file1_size = std::filesystem::file_size(file1, error_code);
    if (error_code)
        return false;

    auto file2_size = std::filesystem::file_size(file2, error_code);
    if (error_code)
        return false;

    // Files must have the same size
    return file1_size == file2_size;
}

/**
 * @brief Check if two files are equal by comparing their contents.
 *
 * @param file1 First file.
 * @param file2 Second file.
 * @return True if the files are equal, false otherwise.
 */
inline bool files_are_equal(const std::filesystem::path &file1,
                            const std::filesystem::path &file2) {
    // Files must have the same size to be equal
    if (!files_have_same_size(file1, file2))
        return false;

    // Streams used to read the files
    std::ifstream file1_stream(file1, std::ios::binary);
    std::ifstream file2_stream(file2, std::ios::binary);

    constexpr size_t buffer_size = 32 * 1024; // 32 KiB
    char file1_buffer[buffer_size];
    char file2_buffer[buffer_size];

    // Compares the contents of the files
    while (file1_stream && file2_stream) {
        file1_stream.read(file1_buffer, buffer_size);
        file2_stream.read(file2_buffer, buffer_size);

        // Number of read bytes (files have the same size, so just get the size
        // of one of them)
        std::streamsize num_read_bytes = file1_stream.gcount();

        // Compares the buffer contents
        if (std::memcmp(file1_buffer, file2_buffer, num_read_bytes) != 0)
            return false;
    }

    return true;
}
