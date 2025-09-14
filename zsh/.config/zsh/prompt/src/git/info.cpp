#include "info.hpp"
#include "../sys/exec.hpp"

#include <algorithm>
#include <fstream>
#include <optional>

namespace git {

GitInfo::GitInfo(const std::filesystem::path *base_search_dir) {
    // Query the first Git repository
    const std::filesystem::path first_search_dir =
        (base_search_dir != nullptr) ? *base_search_dir
                                     : std::filesystem::current_path();

    auto begin = first_search_dir.begin();
    auto end = first_search_dir.end();

    std::filesystem::path base_dir = first_search_dir.parent_path();

    for (auto sub_path = --end; sub_path != begin; --sub_path) {
        std::filesystem::path possible_repository = base_dir / (*sub_path);

        if (std::filesystem::is_directory(possible_repository / ".git")) {
            this->repository_ = std::move(possible_repository);
            break;
        }

        base_dir = base_dir.parent_path();
    }
}

const std::optional<std::filesystem::path> &
GitInfo::get_repository_root() const {
    return this->repository_;
}

const std::optional<std::string> &GitInfo::get_branch() {
    if (!this->branch_.has_value())
        this->update_branch_info();

    return this->branch_;
}

const std::optional<bool> GitInfo::is_detached() {
    if (!this->is_detached_)
        this->update_branch_info();

    return this->is_detached_;
}

const std::optional<std::string> GitInfo::get_git_user() {
    if (!this->git_user_.has_value()) {
        auto [output, result] = sys::exec("git config user.name");

        // Removes the last '\n'
        if (result == 0) {
            std::string::size_type index = output.find('\n');
            this->git_user_ = output.substr(0, index);
        }
    }

    return this->git_user_;
}

void GitInfo::update_branch_info() {
    std::ifstream head_file =
        std::ifstream(this->repository_.value() / ".git/HEAD");

    if (!head_file.is_open()) {
        return;
    }

    char first_line[1000];
    head_file.getline(first_line, 1000);

    char *end_pointer = std::find(first_line, first_line + 1000, '\0');
    char matches[] = "/";
    char *start_pointer =
        std::find_end(first_line, end_pointer, matches, matches + 1);

    if (start_pointer != end_pointer)
        this->branch_ = std::string(++start_pointer);

    // Repository is detached
    else {
        this->branch_ = std::string(
            first_line,
            7); // Use the 7 first characters of the commit as a identifier
    }
}

} // namespace git
