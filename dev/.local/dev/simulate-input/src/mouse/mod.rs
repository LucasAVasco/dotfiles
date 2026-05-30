use anyhow::{Context, Result};

pub mod interface;
mod wayland;
mod xorg;

/// Factory function that returns a mouse simulator based on the current environment.
///
/// It detects if the application is running under Wayland by checking the `WAYLAND_DISPLAY`
/// environment variable. If found, it returns a Wayland simulator; otherwise, it defaults
/// to an Xorg simulator.
pub fn get_mouse_simulator() -> Result<Box<dyn interface::Simulator>> {
    if std::env::var("WAYLAND_DISPLAY").is_ok() {
        let simulator =
            wayland::MouseSimulator::new().context("failed to create wayland mouse simulator")?;
        Ok(Box::new(simulator))
    } else {
        let simulator =
            xorg::MouseSimulator::new().context("failed to create Xorg mouse simulator")?;
        Ok(Box::new(simulator))
    }
}
