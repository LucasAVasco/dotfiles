/**
 * @file
 * @brief Class to iterate over the files that differ between two folders.
 */

#pragma once

#include "./files.hpp"
#include <functional>

/**
 * @class DiffDir
 * @brief Class to iterate over the files that differ between two folders.
 *
 */
class DiffDir {
    ///< The callback that receives the path of the files that
    ///< are different.
    typedef std::function<void(const std::filesystem::path &rel)> callback_t;

  public:
    /**
     * @brief Create a DiffDir object.
     *
     * @param callback The callback that receives the path of the files that are
     * different.
     */
    DiffDir(callback_t callback) : _callback(callback) {}

    /**
     * @brief Iterates over the files that differ between two folders. The
     * files that are different are passed to the callback.
     *
     * @param dir1 First folder.
     * @param dir2 Second folder.
     */
    void iterate(const std::filesystem::path &dir1,
                 const std::filesystem::path &dir2) {
        _iterate(dir1, dir2);
    }

  private:
    /**
     * @brief Calls the callback with a relative path.
     *
     * You must call this function only with the 'rel' path that is accumulated
     * over the recursive calls.
     *
     * @param rel Accumulated relative path.
     */
    inline void _call_to_rel(const std::filesystem::path &rel) {
        _callback(rel);
    }

    /**
     * @brief Calls the callback with all elements of a directory.
     *
     * You must call this function only with the 'rel' path that is accumulated
     * over the recursive calls.
     *
     * @param dir Path of the directory.
     * @param rel Accumulated relative path.
     */
    inline void _call_to_dir(const std::filesystem::path &dir,
                             const std::filesystem::path &rel = "") {
        _call_to_rel(dir);

        for (auto &sub_path : std::filesystem::directory_iterator(dir)) {
            const auto sub_rel =
                std::filesystem::relative(sub_path.path(), dir);

            if (std::filesystem::is_directory(sub_path)) {
                _call_to_dir(sub_path, rel / sub_rel);
            } else { // Is file
                _call_to_rel(rel / sub_rel);
            }
        }
    }

    /**
     * @brief Iterates over the files that differ between two folders.
     *
     * @param dir1 First folder.
     * @param dir2 Second folder.
     * @param rel Recursive relative path accumulated over the recursive calls.
     */
    inline void _iterate(const std::filesystem::path &dir1,
                         const std::filesystem::path &dir2,
                         const std::filesystem::path &rel = "") {
        // Compares the 'dir1/' files with 'dir2/'
        for (auto &sub_path1 : std::filesystem::directory_iterator(dir1)) {
            const auto sub_rel = // Sub path relative to 'dir1/'
                std::filesystem::relative(sub_path1.path(), dir1);

            const auto next_rel = rel / sub_rel; // Next 'rel' level

            const auto sub_path2 = dir2 / sub_rel; // Equivalent file in 'dir2/'

            // Comparison between sub files
            if (std::filesystem::is_regular_file(sub_path1)) {
                if (std::filesystem::is_regular_file(sub_path2)) {
                    if (!files_are_equal(sub_path1.path(), sub_path2))
                        _call_to_rel(next_rel);

                } else if (std::filesystem::is_directory(sub_path2)) {
                    _call_to_rel(next_rel);
                    _call_to_dir(sub_path2, next_rel);

                } else { // sub_path2 is does not exist
                    _call_to_rel(next_rel);
                }
            } else { // sub_path1 is directory
                if (std::filesystem::is_directory(sub_path2)) {
                    _iterate(sub_path1, sub_path2, next_rel);

                } else if (std::filesystem::is_regular_file(sub_path2)) {
                    _call_to_dir(sub_path1, next_rel);
                } else { // sub_path2 is does not exist
                    _call_to_dir(sub_path1, next_rel);
                }
            }
        }

        // Compares the 'dir2/' files with 'dir1/'
        for (auto &sub_path2 : std::filesystem::directory_iterator(dir2)) {
            const auto sub_rel = // Sub path relative to 'dir2/'
                std::filesystem::relative(sub_path2.path(), dir2);

            const auto next_rel = rel / sub_rel; // Next 'rel' level

            const auto sub_path1 = dir1 / sub_rel; // Equivalent file in 'dir1/'

            // Only need to check if the sub path of 'dir2/' does not exist in
            // 'dir1/' because the other cases have already been checked
            if (!std::filesystem::exists(sub_path1)) {
                if (std::filesystem::is_regular_file(sub_path2)) {
                    _call_to_rel(next_rel);
                } else {
                    _call_to_dir(sub_path2, next_rel);
                }
            }
        }
    }

    const callback_t _callback;
};
