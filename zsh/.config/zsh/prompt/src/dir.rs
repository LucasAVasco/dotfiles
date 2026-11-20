pub fn replace_home_by_tilde(directory: &str, home: &str) -> String {
    if directory.starts_with('~') {
        return directory.to_string();
    }

    let trimmed_home = home.trim_end_matches('/');
    if trimmed_home.is_empty() || trimmed_home == " " {
        return directory.to_string();
    }

    if directory == trimmed_home {
        "~".to_string()
    } else if let Some(rest) = directory.strip_prefix(trimmed_home) {
        if rest.starts_with('/') {
            format!("~{rest}")
        } else {
            directory.to_string()
        }
    } else {
        directory.to_string()
    }
}

pub fn format_current_directory(
    pwd: &str,
    home: &str,
    simplify: bool,
    compact_tilde: bool,
) -> String {
    if pwd == "/" || pwd.is_empty() {
        return "/".to_string();
    }

    let working = if compact_tilde {
        replace_home_by_tilde(pwd, home)
    } else {
        pwd.to_string()
    };

    if working == "~" {
        return "~".to_string();
    }

    let (prefix, rest) = if let Some(after_tilde) = working.strip_prefix("~/") {
        ("~", after_tilde)
    } else if let Some(after_slash) = working.strip_prefix('/') {
        ("", after_slash)
    } else {
        ("", working.as_str())
    };

    let components: Vec<&str> = rest.split('/').filter(|c| !c.is_empty()).collect();
    if components.is_empty() {
        return if prefix.is_empty() {
            "/".to_string()
        } else {
            prefix.to_string()
        };
    }

    let mut res = String::from(prefix);
    let last_idx = components.len() - 1;

    for (idx, component) in components.iter().enumerate() {
        res.push('/');
        if simplify && idx < last_idx {
            let mut chars = component.chars();
            if let Some(first) = chars.next() {
                res.push(first);
                if first == '.'
                    && let Some(second) = chars.next()
                {
                    res.push(second);
                }
            }
        } else {
            res.push_str(component);
        }
    }

    res
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn formats_home_and_subdirectories() {
        let home = "/home/lucas_dev";
        assert_eq!(format_current_directory(home, home, false, true), "~");
        assert_eq!(format_current_directory(home, home, true, true), "~");
        assert_eq!(
            format_current_directory("/home/lucas_dev/.config/zsh/prompt", home, false, true),
            "~/.config/zsh/prompt"
        );
        assert_eq!(
            format_current_directory("/home/lucas_dev/.config/zsh/prompt", home, true, true),
            "~/.c/z/prompt"
        );
    }

    #[test]
    fn formats_root_and_container_root_home() {
        assert_eq!(format_current_directory("/", "/root", true, true), "/");
        assert_eq!(format_current_directory("/root", "/root", true, true), "~");
        assert_eq!(
            format_current_directory("/root/app/src", "/root", true, true),
            "~/a/src"
        );
        assert_eq!(
            format_current_directory("/var/log/nginx", "/home/user", true, true),
            "/v/l/nginx"
        );
    }

    #[test]
    fn handles_utf8_directory_names() {
        assert_eq!(
            format_current_directory("/home/user/日本語/proj", "/home/user", true, true),
            "~/日/proj"
        );
        assert_eq!(
            format_current_directory("/home/user/.ábc/proj", "/home/user", true, true),
            "~/.á/proj"
        );
    }
}
