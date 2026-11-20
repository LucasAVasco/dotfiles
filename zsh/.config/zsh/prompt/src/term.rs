use std::fmt::Write;

pub const OPEN_ESCAPE: &str = "%{";
pub const CLOSE_ESCAPE: &str = "%}";
pub const OPEN_ICON_ESCAPE: &str = "%1{";
pub const CLOSE_ICON_ESCAPE: &str = "%}";

pub const RESET_BG: &str = "%{\x1b[49m%}";

pub const STYLE_NORMAL: &str = "%{\x1b[0m%}";
pub const STYLE_BOLD: &str = "%{\x1b[1m%}";
pub const STYLE_ITALIC: &str = "%{\x1b[3m%}";

#[inline]
fn parse_hex_byte(hi: u8, lo: u8) -> u8 {
    fn hex_val(b: u8) -> u8 {
        match b {
            b'0'..=b'9' => b - b'0',
            b'A'..=b'F' => b - b'A' + 10,
            b'a'..=b'f' => b - b'a' + 10,
            _ => 0,
        }
    }
    (hex_val(hi) << 4) | hex_val(lo)
}

pub fn push_fg(buf: &mut String, hex: &str) {
    let bytes = hex.as_bytes();
    let (r, g, b) = if bytes.len() >= 7 && bytes[0] == b'#' {
        (
            parse_hex_byte(bytes[1], bytes[2]),
            parse_hex_byte(bytes[3], bytes[4]),
            parse_hex_byte(bytes[5], bytes[6]),
        )
    } else {
        (0, 0, 0)
    };
    let _ = write!(buf, "%{{\x1b[38;2;{r};{g};{b}m%}}");
}

pub fn push_bg(buf: &mut String, hex: &str) {
    let bytes = hex.as_bytes();
    let (r, g, b) = if bytes.len() >= 7 && bytes[0] == b'#' {
        (
            parse_hex_byte(bytes[1], bytes[2]),
            parse_hex_byte(bytes[3], bytes[4]),
            parse_hex_byte(bytes[5], bytes[6]),
        )
    } else {
        (0, 0, 0)
    };
    let _ = write!(buf, "%{{\x1b[48;2;{r};{g};{b}m%}}");
}

pub fn repeat_escape(buf: &mut String, code: &str, times: u32) {
    for _ in 0..times {
        buf.push_str(code);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rgb_escapes_match_expected() {
        let mut s = String::new();
        push_fg(&mut s, "#2a2a30");
        assert_eq!(s, "%{\x1b[38;2;42;42;48m%}");

        s.clear();
        push_bg(&mut s, "#2a2a30");
        assert_eq!(s, "%{\x1b[48;2;42;42;48m%}");

        s.clear();
        push_fg(&mut s, "#ffbb00");
        assert_eq!(s, "%{\x1b[38;2;255;187;0m%}");
    }
}
