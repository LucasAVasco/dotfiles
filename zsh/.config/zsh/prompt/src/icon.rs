use crate::dir::replace_home_by_tilde;
use crate::term::{CLOSE_ICON_ESCAPE, OPEN_ICON_ESCAPE};

pub const RIGHT_SEMICIRCLE: &str = "";
pub const LEFT_SEMICIRCLE: &str = "";
pub const RIGHT_TRIANGLE: &str = "";
pub const RIGHT_TRIANGLE_INV: &str = "";

pub const DEFAULT_DIR_ICON: &str = "";
const FONTS_ICON: &str = "󰊄";
const ICONS_ICON: &str = "";
const THEMES_ICON: &str = "";

pub fn push_icon(buf: &mut String, glyph: &str) {
    buf.push_str(OPEN_ICON_ESCAPE);
    buf.push_str(glyph);
    buf.push_str(CLOSE_ICON_ESCAPE);
}

pub fn get_directory_icon(directory: &str, home: &str) -> &'static str {
    let minimized = if directory.starts_with('~') {
        directory.to_string()
    } else {
        replace_home_by_tilde(directory, home)
    };

    match minimized.as_str() {
        // Home directories
        "~" => "",
        "~/Desktop" => "󰧨",
        "~/Documents" => "󰈙",
        "~/Downloads" => "",
        "~/Games" => "",
        "~/Music" => "",
        "~/Notes" => "",
        "~/Pictures" => "󰄀",
        "~/Public" => "",
        "~/Repositories" => "󰳏",
        "~/Sync" => "",
        "~/Templates" => "󱐁",
        "~/Videos" => "󰨜",

        // Home hidden folders
        "~/.cache" => "",
        "~/.config" => "",
        "~/.fonts" | "~/.local/share/fonts" => FONTS_ICON,
        "~/.icons" | "~/.local/share/icons" => ICONS_ICON,
        "~/.themes" | "~/.local/share/themes" => THEMES_ICON,

        // Non-home directories
        "/" => "",
        "/var/log" => "",

        _ => DEFAULT_DIR_ICON,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn resolves_known_and_default_directory_icons() {
        assert_eq!(get_directory_icon("/home/alice", "/home/alice"), "");
        assert_eq!(get_directory_icon("/home/alice/.config", "/home/alice"), "");
        assert_eq!(get_directory_icon("/var/log", "/home/alice"), "");
        assert_eq!(get_directory_icon("/", "/home/alice"), "");
        assert_eq!(
            get_directory_icon("/home/alice/unknown", "/home/alice"),
            DEFAULT_DIR_ICON
        );
    }
}
