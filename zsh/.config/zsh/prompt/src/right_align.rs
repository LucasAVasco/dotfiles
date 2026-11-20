use crate::icon::push_icon;
use crate::term::push_fg;

pub struct RightAlignedLine {
    buf: String,
    visible_chars: usize,
}

impl RightAlignedLine {
    pub fn new() -> Self {
        Self {
            buf: String::with_capacity(128),
            visible_chars: 0,
        }
    }

    pub fn push_fg(&mut self, hex: &str) {
        push_fg(&mut self.buf, hex);
    }

    pub fn push_icon(&mut self, glyph: &str) {
        push_icon(&mut self.buf, glyph);
        self.visible_chars += 1;
    }

    pub fn push_text(&mut self, text: &str) {
        self.buf.push_str(text);
        self.visible_chars += text.chars().count();
    }

    pub fn write_to(self, out: &mut String, columns: u32) {
        let cols = columns as usize;
        if self.visible_chars < cols {
            for _ in 0..(cols - self.visible_chars) {
                out.push(' ');
            }
        }
        out.push_str(&self.buf);
        out.push('\n');
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pads_to_terminal_columns() {
        let mut line = RightAlignedLine::new();
        line.push_fg("#bbbb00");
        line.push_icon("");
        line.push_text(" hi");

        let mut out = String::new();
        line.write_to(&mut out, 10);
        // 1 (icon) + 3 (" hi") = 4 visible chars -> 6 spaces
        assert_eq!(out, "      %{\x1b[38;2;187;187;0m%}%1{%} hi\n");
    }

    #[test]
    fn no_padding_when_wider_than_columns() {
        let mut line = RightAlignedLine::new();
        line.push_text("hello world");

        let mut out = String::new();
        line.write_to(&mut out, 5);
        assert_eq!(out, "hello world\n");
    }
}
