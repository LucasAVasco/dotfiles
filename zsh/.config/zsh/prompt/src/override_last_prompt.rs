use crate::cli::Args;
use crate::term::repeat_escape;

pub fn render(args: &Args) -> String {
    let number_lines_to_move = args.cmd_lines_num.saturating_add(2);
    let mut out = String::with_capacity(64);

    repeat_escape(&mut out, &args.terminfo_move_cursor_up, number_lines_to_move);
    repeat_escape(&mut out, &args.terminfo_delete_line, 2);
    repeat_escape(
        &mut out,
        &args.terminfo_move_cursor_down,
        number_lines_to_move.saturating_sub(1),
    );

    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn emits_expected_cursor_sequences() {
        let args = Args {
            cmd_lines_num: 3,
            terminfo_move_cursor_up: "<UP>".to_string(),
            terminfo_move_cursor_down: "<DN>".to_string(),
            terminfo_delete_line: "<DL>".to_string(),
            ..Args::default()
        };

        assert_eq!(
            render(&args),
            "<UP><UP><UP><UP><UP><DL><DL><DN><DN><DN><DN>"
        );
    }
}
