use anyhow::{Context, Result};
use clap::{Parser, Subcommand, ValueEnum};

mod mouse;

/// Command-line interface for controlling the mouse.
#[derive(Parser)]
#[command(name = "mouse-cli")]
#[command(about = "Control the mouse via command line", version = "1.0")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

/// Available top-level commands.
#[derive(Subcommand)]
enum Commands {
    /// Mouse-related commands
    Mouse {
        #[command(subcommand)]
        action: MouseActions,
    },
}

/// Actions that can be performed with the mouse.
#[derive(Subcommand)]
enum MouseActions {
    /// Click a mouse button
    Click {
        /// The button to click
        #[arg(value_enum)]
        button: MouseButton,
    },
    /// Scroll the mouse wheel with repetitions and offsets
    Scroll {
        /// Number of times to repeat the scroll
        repeat: u32,

        /// Delay in milliseconds between each repetition
        delay: u64,

        /// Horizontal scroll offset (X axis)
        #[arg(allow_negative_numbers = true)]
        dx: i32,

        /// Vertical scroll offset (Y axis)
        #[arg(allow_negative_numbers = true)]
        dy: i32,
    },
}

/// Supported mouse buttons.
#[derive(ValueEnum, Clone, Copy, Debug)]
enum MouseButton {
    Left,
    Right,
    Middle,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    // Initialize the mouse simulator based on the current environment (Xorg/Wayland)
    let mut mouse_simulator = mouse::get_mouse_simulator()?;

    match cli.command {
        Commands::Mouse { action } => match action {
            MouseActions::Click { button } => {
                let button = match button {
                    MouseButton::Left => mouse::interface::MouseButton::Left,
                    MouseButton::Right => mouse::interface::MouseButton::Right,
                    MouseButton::Middle => mouse::interface::MouseButton::Middle,
                };
                mouse_simulator
                    .click(button)
                    .context("failed to simulate click")?
            }
            MouseActions::Scroll {
                repeat,
                delay,
                dx,
                dy,
            } => {
                for _ in 0..repeat {
                    mouse_simulator
                        .scroll(dx, dy)
                        .context("failed to simulate scroll")?;
                    std::thread::sleep(std::time::Duration::from_millis(delay));
                }
            }
        },
    }

    Ok(())
}
