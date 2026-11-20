use std::fmt::Write;
use std::process::{Command, Stdio};

use crate::cli::Args;
use crate::config;
use crate::dir::format_current_directory;
use crate::env::EnvVars;
use crate::git::GitInfo;
use crate::icon::{
    LEFT_SEMICIRCLE, RIGHT_SEMICIRCLE, RIGHT_TRIANGLE, RIGHT_TRIANGLE_INV, get_directory_icon,
    push_icon,
};
use crate::right_align::RightAlignedLine;
use crate::term::{
    CLOSE_ESCAPE, OPEN_ESCAPE, RESET_BG, STYLE_BOLD, STYLE_ITALIC, STYLE_NORMAL, push_bg, push_fg,
    repeat_escape,
};
use crate::time::format_local_datetime;

fn push_main_prompt_separator(out: &mut String, next_bg_hex: &str) {
    push_fg(out, config::SEPARATOR_COLOR);
    push_icon(out, RIGHT_TRIANGLE_INV);
    push_bg(out, next_bg_hex);
    push_icon(out, RIGHT_TRIANGLE);
}

fn is_sudo_cached() -> bool {
    Command::new("sudo")
        .args(["-n", "true"])
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

pub fn render(args: &Args) -> String {
    let env_vars = EnvVars::load();
    let mut out = String::with_capacity(1024);

    // Remove last prompt if it is empty (the user pressed Enter without a command)
    if args.mv_prompt_down == 1 {
        out.push_str(OPEN_ESCAPE);
        repeat_escape(&mut out, &args.terminfo_move_cursor_up, 4);
        for _ in 0..4 {
            out.push_str(&args.terminfo_clear_line);
            out.push_str(&args.terminfo_move_cursor_down);
        }
        out.push_str(CLOSE_ESCAPE);
    } else {
        out.push('\n');
    }

    // Separator between commands
    if args.show_cmd_separator > 0 {
        out.push('\n');
        out.push_str(OPEN_ESCAPE);

        out.push_str(STYLE_ITALIC);
        out.push_str(STYLE_BOLD);
        if args.last_cmd_error == 0 {
            push_fg(&mut out, config::SUCCESS_COLOR);
            out.push_str(" ");
        } else {
            push_fg(&mut out, config::ERROR_COLOR);
            out.push_str(" ");
        }

        let error_code_str = args.last_cmd_error.to_string();
        out.push_str(&error_code_str);
        out.push_str(STYLE_NORMAL);
        out.push(' ');
        push_fg(&mut out, config::CMD_SEPARATOR_COLOR);

        // Elapsed time
        repeat_escape(&mut out, "", 5);

        let elapsed_time = args.time_now - args.cmd_start_time;
        let elapsed_time_str = format!("{elapsed_time:.6}");
        push_fg(&mut out, config::TIME_COLOR);
        out.push_str(" 󱦟 ");
        out.push_str(&elapsed_time_str);
        out.push_str("s ");
        push_fg(&mut out, config::CMD_SEPARATOR_COLOR);

        let used_cols = 2 + error_code_str.len() + 1 + elapsed_time_str.len() + 5 + 5;
        let total_cols = args.columns as usize;
        if total_cols > used_cols {
            repeat_escape(&mut out, "", (total_cols - used_cols) as u32);
        }

        out.push_str(CLOSE_ESCAPE);
        out.push('\n');
    }

    // First prompt line (right aligned)
    {
        let mut right = RightAlignedLine::new();
        let now_str = format_local_datetime();
        right.push_fg(config::DATE_COLOR);
        right.push_icon("");
        right.push_text(" ");
        right.push_text(&now_str);
        right.push_text("     ");

        let current_dir = format_current_directory(&env_vars.pwd, &env_vars.home, false, true);
        right.push_fg(config::CWD_COLOR);
        right.push_icon("");
        right.push_text(" ");
        right.push_text(&current_dir);
        right.write_to(&mut out, args.columns);
    }

    // Second prompt line (main prompt)
    push_fg(&mut out, config::BASE_COLOR);
    push_icon(&mut out, LEFT_SEMICIRCLE);
    push_bg(&mut out, config::BASE_COLOR);
    push_fg(&mut out, config::SHELL_LEVEL_COLOR);
    push_icon(&mut out, "");
    out.push(' ');
    out.push_str(&env_vars.shlvl);
    out.push(' ');

    // User name
    out.push_str(&env_vars.user_name);
    out.push(' ');

    // Git info
    if let Ok(physical_cwd) = std::env::current_dir()
        && let Some(git_info) = GitInfo::discover(&physical_cwd)
    {
        push_fg(&mut out, config::GIT_COLOR);

        if let Some(git_user) = git_info.git_user() {
            push_icon(&mut out, "");
            out.push(' ');
            out.push_str(&git_user);
            out.push(' ');
        }

        if let Some(branch) = git_info.branch() {
            push_icon(&mut out, "");
            out.push(' ');
            out.push_str(&branch);
            out.push(' ');
        }
    }

    // Current working directory
    push_main_prompt_separator(&mut out, config::CWD_COLOR);
    let cwd = format_current_directory(&env_vars.pwd, &env_vars.home, true, true);
    push_fg(&mut out, config::BASE_COLOR);
    out.push_str(STYLE_BOLD);
    out.push(' ');
    push_icon(&mut out, get_directory_icon(&env_vars.pwd, &env_vars.home));
    out.push(' ');
    out.push_str(&cwd);
    push_fg(&mut out, config::CWD_COLOR);
    out.push_str(RESET_BG);
    push_icon(&mut out, RIGHT_SEMICIRCLE);
    out.push_str(STYLE_NORMAL);

    // User input line
    out.push_str("\n\n");

    // Inside container indicator
    if env_vars.running_inside_container == "y" {
        push_fg(&mut out, config::CONTAINER_INDICATOR_COLOR);
        push_icon(&mut out, LEFT_SEMICIRCLE);
        push_bg(&mut out, config::CONTAINER_INDICATOR_COLOR);
        push_fg(&mut out, config::CONTAINER_INDICATOR_TEXT);
        out.push_str(STYLE_BOLD);
        push_icon(&mut out, "");
        push_fg(&mut out, config::CONTAINER_INDICATOR_COLOR);
        out.push_str(RESET_BG);
        push_fg(&mut out, config::CONTAINER_INDICATOR_COLOR);
        push_icon(&mut out, RIGHT_SEMICIRCLE);
        out.push(' ');
    }

    // Sudo enabled indicator
    if is_sudo_cached() {
        push_fg(&mut out, config::SUDO_ENABLED_INDICATOR_BG);
        push_icon(&mut out, LEFT_SEMICIRCLE);
        push_bg(&mut out, config::SUDO_ENABLED_INDICATOR_BG);
        push_fg(&mut out, config::SUDO_ENABLED_INDICATOR_FG);
        out.push_str(STYLE_BOLD);
        out.push(' ');
        push_icon(&mut out, "󰒃");
        out.push_str(" ROOT ");
        push_fg(&mut out, config::SUDO_ENABLED_INDICATOR_BG);
        out.push_str(RESET_BG);
        push_fg(&mut out, config::SUDO_ENABLED_INDICATOR_BG);
        push_icon(&mut out, RIGHT_SEMICIRCLE);
        out.push(' ');
    }

    // Command number
    push_fg(&mut out, config::ARROW_COLOR_1);
    push_icon(&mut out, LEFT_SEMICIRCLE);
    push_bg(&mut out, config::ARROW_COLOR_1);
    push_fg(&mut out, config::CMD_NUM_COLOR);
    let _ = write!(out, "{}", args.cmd_number);
    push_fg(&mut out, config::ARROW_COLOR_1);
    out.push_str(RESET_BG);
    push_fg(&mut out, config::ARROW_COLOR_1);
    push_icon(&mut out, RIGHT_TRIANGLE);

    // Arrows
    push_fg(&mut out, config::ARROW_COLOR_2);
    push_icon(&mut out, RIGHT_TRIANGLE_INV);
    push_icon(&mut out, RIGHT_TRIANGLE);
    push_fg(&mut out, config::ARROW_COLOR_3);
    push_icon(&mut out, RIGHT_TRIANGLE_INV);
    push_icon(&mut out, RIGHT_TRIANGLE);

    out.push_str("  ");
    out
}
