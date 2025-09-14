#pragma once

#include <filesystem>
#include <optional>
#include <string>

namespace git {

class GitInfo {
  public:
    GitInfo(const std::filesystem::path *repository = nullptr);

    [[nodiscard]] const std::optional<std::filesystem::path> &
    get_repository_root() const;

    [[nodiscard]] const std::optional<std::string> &get_branch();
    [[nodiscard]] const std::optional<bool> is_detached();
    [[nodiscard]] const std::optional<std::string> get_git_user();

  private:
    void update_branch_info();
    std::optional<std::filesystem::path> repository_;
    std::optional<std::string> branch_;
    std::optional<bool> is_detached_;
    std::optional<std::string> git_user_;
};

} // namespace git
