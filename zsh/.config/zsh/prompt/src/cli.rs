use std::env;

pub const ENV_TERMINFO_MV_CURSOR_UP: &str = "PROMPT_TERMINFO_MV_CURSOR_UP";
pub const ENV_TERMINFO_MV_CURSOR_DOWN: &str = "PROMPT_TERMINFO_MV_CURSOR_DOWN";
pub const ENV_TERMINFO_CLEAR_LINE: &str = "PROMPT_TERMINFO_CLEAR_LINE";
pub const ENV_TERMINFO_DELETE_LINE: &str = "PROMPT_TERMINFO_DELETE_LINE";

#[derive(Debug, Default, PartialEq)]
pub struct Args {
    pub columns: u32,
    pub cmd_number: u32,
    pub last_cmd_error: i32,
    pub cmd_start_time: f64,
    pub time_now: f64,
    pub show_cmd_separator: u32,
    pub cmd_lines_num: u32,
    pub mv_prompt_down: i32,

    pub terminfo_move_cursor_up: String,
    pub terminfo_move_cursor_down: String,
    pub terminfo_clear_line: String,
    pub terminfo_delete_line: String,
}

pub fn parse_args(raw_args: &[String]) -> Args {
    parse_args_with_env(raw_args, |key| env::var(key).ok())
}

pub fn parse_args_with_env<F>(raw_args: &[String], get_env: F) -> Args
where
    F: Fn(&str) -> Option<String>,
{
    let mut args = Args {
        terminfo_move_cursor_up: get_env(ENV_TERMINFO_MV_CURSOR_UP).unwrap_or_default(),
        terminfo_move_cursor_down: get_env(ENV_TERMINFO_MV_CURSOR_DOWN).unwrap_or_default(),
        terminfo_clear_line: get_env(ENV_TERMINFO_CLEAR_LINE).unwrap_or_default(),
        terminfo_delete_line: get_env(ENV_TERMINFO_DELETE_LINE).unwrap_or_default(),
        ..Args::default()
    };

    let mut i = 0;
    while i + 1 < raw_args.len() {
        let key = raw_args[i].as_str();
        let val = raw_args[i + 1].as_str();
        i += 2;

        match key {
            "--columns" => args.columns = parse_u32(val),
            "--cmd-num" => args.cmd_number = parse_u32(val),
            "--show-cmd-separator" => args.show_cmd_separator = parse_u32(val),
            "--cmd-lines-num" => args.cmd_lines_num = parse_u32(val),
            "--last-error" => args.last_cmd_error = parse_i32(val),
            "--mv-prompt-down" => args.mv_prompt_down = parse_i32(val),
            "--cmd-start-time" => args.cmd_start_time = parse_f64(val),
            "--time-now" => args.time_now = parse_f64(val),
            "--terminfo-mv-cursor-up" => args.terminfo_move_cursor_up = val.to_string(),
            "--terminfo-mv-cursor-down" => args.terminfo_move_cursor_down = val.to_string(),
            "--terminfo-clear-line" => args.terminfo_clear_line = val.to_string(),
            "--terminfo-delete-line" => args.terminfo_delete_line = val.to_string(),
            _ => eprintln!("Unknown argument: {key}"),
        }
    }

    args
}

fn parse_u32(s: &str) -> u32 {
    if s.is_empty() {
        0
    } else {
        s.parse().unwrap_or(0)
    }
}

fn parse_i32(s: &str) -> i32 {
    if s.is_empty() {
        0
    } else {
        s.parse().unwrap_or(0)
    }
}

fn parse_f64(s: &str) -> f64 {
    if s.is_empty() {
        0.0
    } else {
        s.parse().unwrap_or(0.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn to_strings(slice: &[&str]) -> Vec<String> {
        slice.iter().map(|s| (*s).to_string()).collect()
    }

    #[test]
    fn terminfo_from_env_with_cli_override() {
        let raw = to_strings(&[
            "--columns",
            "120",
            "--cmd-num",
            "4",
            "--last-error",
            "1",
            "--cmd-start-time",
            "10.5",
            "--time-now",
            "12.0",
            "--terminfo-mv-cursor-up",
            "CLI_UP",
        ]);

        let args = parse_args_with_env(&raw, |k| match k {
            ENV_TERMINFO_MV_CURSOR_UP => Some("ENV_UP".to_string()),
            ENV_TERMINFO_MV_CURSOR_DOWN => Some("ENV_DOWN".to_string()),
            ENV_TERMINFO_CLEAR_LINE => Some("ENV_CLEAR".to_string()),
            ENV_TERMINFO_DELETE_LINE => Some("ENV_DEL".to_string()),
            _ => None,
        });

        assert_eq!(args.columns, 120);
        assert_eq!(args.cmd_number, 4);
        assert_eq!(args.last_cmd_error, 1);
        assert_eq!(args.cmd_start_time, 10.5);
        assert_eq!(args.time_now, 12.0);
        assert_eq!(args.terminfo_move_cursor_up, "CLI_UP");
        assert_eq!(args.terminfo_move_cursor_down, "ENV_DOWN");
        assert_eq!(args.terminfo_clear_line, "ENV_CLEAR");
        assert_eq!(args.terminfo_delete_line, "ENV_DEL");
    }

    #[test]
    fn empty_numeric_values_default_to_zero() {
        let raw = to_strings(&["--columns", "", "--last-error", "", "--cmd-start-time", ""]);
        let args = parse_args_with_env(&raw, |_| None);
        assert_eq!(args.columns, 0);
        assert_eq!(args.last_cmd_error, 0);
        assert_eq!(args.cmd_start_time, 0.0);
        assert_eq!(args.terminfo_move_cursor_up, "");
    }
}
