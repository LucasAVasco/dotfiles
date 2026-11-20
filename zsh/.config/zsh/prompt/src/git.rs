use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

pub struct GitInfo {
    repo_root: PathBuf,
}

impl GitInfo {
    pub fn discover(start_dir: &Path) -> Option<Self> {
        for ancestor in start_dir.ancestors() {
            if ancestor.join(".git").is_dir() {
                return Some(Self {
                    repo_root: ancestor.to_path_buf(),
                });
            }
        }
        None
    }

    pub fn branch(&self) -> Option<String> {
        let head_content = fs::read_to_string(self.repo_root.join(".git/HEAD")).ok()?;
        parse_head_content(&head_content)
    }

    pub fn git_user(&self) -> Option<String> {
        let output = Command::new("git")
            .args(["config", "user.name"])
            .output()
            .ok()?;

        if !output.status.success() {
            return None;
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        let first_line = stdout.lines().next().unwrap_or("");
        Some(first_line.to_string())
    }
}

fn parse_head_content(content: &str) -> Option<String> {
    let first_line = content.lines().next()?.trim();
    if first_line.is_empty() {
        return None;
    }

    if let Some((_, branch)) = first_line.rsplit_once('/') {
        Some(branch.to_string())
    } else {
        Some(first_line.chars().take(7).collect())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_standard_branch_head() {
        assert_eq!(
            parse_head_content("ref: refs/heads/main\n"),
            Some("main".to_string())
        );
    }

    #[test]
    fn parses_detached_head_commit() {
        assert_eq!(
            parse_head_content("a1b2c3d4e5f67890abcdef1234567890abcdef12\n"),
            Some("a1b2c3d".to_string())
        );
    }
}
