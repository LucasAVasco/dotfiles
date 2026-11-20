mod cli;
mod config;
mod dir;
mod env;
mod git;
mod icon;
mod left;
mod override_last_prompt;
mod right_align;
mod term;
mod time;

use std::io::{self, Write};
use std::process::ExitCode;

fn main() -> ExitCode {
    let raw_args: Vec<String> = std::env::args().skip(1).collect();
    let Some((subcmd, rest)) = raw_args.split_first() else {
        eprintln!("Usage: zsh-prompt <left|override-last-prompt> [options]");
        return ExitCode::FAILURE;
    };

    let args = cli::parse_args(rest);
    let output = match subcmd.as_str() {
        "left" => left::render(&args),
        "override-last-prompt" => override_last_prompt::render(&args),
        other => {
            eprintln!("Unknown subcommand: {other}");
            return ExitCode::FAILURE;
        }
    };

    let mut stdout = io::stdout().lock();
    let _ = stdout.write_all(output.as_bytes());
    let _ = stdout.flush();

    ExitCode::SUCCESS
}
