use anyhow::Result;

/// Represents the standard buttons of a computer mouse.
#[derive(Debug, Hash, Eq, PartialEq)]
pub enum MouseButton {
    Left,
    Middle,
    Right,
}

/// A trait defining the interface for mouse input simulation.
///
/// Implementors of this trait should provide mechanisms to simulate
/// mouse clicks and scrolling across different display servers or operating systems.
pub trait Simulator {
    /// Simulates a single click of the specified mouse button.
    fn click(&mut self, button: MouseButton) -> Result<()>;

    /// Simulates mouse wheel scrolling.
    ///
    /// `dx` represents horizontal scroll delta, and `dy` represents vertical scroll delta.
    fn scroll(&mut self, dx: i32, dy: i32) -> Result<()>;
}
