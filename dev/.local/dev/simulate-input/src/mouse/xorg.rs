use anyhow::{Context, Result};
use std::collections::HashMap;
use std::os::raw::c_uint;
use std::sync::LazyLock;
use std::time::Duration;
use x11_dl::xlib::{Display, Xlib};
use x11_dl::xtest::Xf86vmode;

use crate::mouse::interface;

/// A mouse simulator that targets Xorg (X11) display servers.
///
/// It uses the XTest extension to inject fake hardware input events into the X server.
pub struct MouseSimulator {
    xlib: Xlib,
    xtest: Xf86vmode,
    display: *mut Display,
}

impl MouseSimulator {
    /// Connects to the active X server display and loads necessary native extensions.
    ///
    /// This function dynamically loads `libX11` and `libXtst` and opens a connection
    /// to the X server specified by the `DISPLAY` environment variable.
    pub fn new() -> Result<Self> {
        // Dynamically link to the shared Xlib library object
        let xlib = Xlib::open().context("failed to dynamically load Xlib (.so) library")?;

        // Dynamically link to the XTest automation extension library object
        let xtest = Xf86vmode::open().context("failed to dynamically load XTest (.so) library")?;

        // Open connection using the default NULL pointer (reads from the $DISPLAY env var)
        let display = unsafe { (xlib.XOpenDisplay)(std::ptr::null()) };
        if display.is_null() {
            return Err(anyhow::anyhow!(
                "failed to connect to the active Xorg display server"
            ));
        }

        Ok(MouseSimulator {
            xlib,
            xtest,
            display,
        })
    }

    /// Internal scroll handler that translates direction deltas into discrete mouse wheel clicks.
    ///
    /// X11 simulates scrolling as a sequence of button press and release events.
    fn scroll_to_direction(&mut self, scroll_button: c_uint, distance: i32) -> Result<()> {
        let steps = distance.abs();

        for _ in 0..steps {
            unsafe {
                // XTest simulates a wheel notch movement via sequential button Press and Release actions
                // 1 means pressed down state
                (self.xtest.XTestFakeButtonEvent)(self.display, scroll_button, 1, 0);
                // 0 means released up state
                (self.xtest.XTestFakeButtonEvent)(self.display, scroll_button, 0, 0);
            }
        }
        Ok(())
    }
}

/// Ensures display contexts are cleaned up to avoid memory leaks in the X server.
impl Drop for MouseSimulator {
    fn drop(&mut self) {
        unsafe {
            (self.xlib.XCloseDisplay)(self.display);
        }
    }
}

impl interface::Simulator for MouseSimulator {
    /// Simulates a mouse button click on Xorg.
    ///
    /// It triggers a press event, waits for a short duration to simulate physical switch travel,
    /// and then triggers a release event.
    fn click(&mut self, button: interface::MouseButton) -> Result<()> {
        let x_button = BUTTON_MAP
            .get(&button)
            .context("unknown Xorg button mapping context")?;

        unsafe {
            // Trigger Mouse Pressed State
            (self.xtest.XTestFakeButtonEvent)(self.display, *x_button, 1, 0);
            (self.xlib.XFlush)(self.display);

            // Brief mechanical physical switch window delay
            std::thread::sleep(Duration::from_millis(50));

            // Trigger Mouse Released State
            (self.xtest.XTestFakeButtonEvent)(self.display, *x_button, 0, 0);
            (self.xlib.XFlush)(self.display);
        }

        Ok(())
    }

    /// Simulates mouse wheel scrolling on Xorg.
    ///
    /// X11 handles scrolling via discrete button indices rather than fluid axis vectors.
    /// - Button 4: Scroll Up
    /// - Button 5: Scroll Down
    /// - Button 6: Scroll Left
    /// - Button 7: Scroll Right
    fn scroll(&mut self, dx: i32, dy: i32) -> Result<()> {
        if dx != 0 {
            let scroll_button = if dx > 0 { 7 } else { 6 };
            self.scroll_to_direction(scroll_button, dx)?;
        }

        if dy != 0 {
            let scroll_button = if dy > 0 { 5 } else { 4 };
            self.scroll_to_direction(scroll_button, dy)?;
        }

        // Push built event sequences out of the display network buffer stream immediately
        unsafe {
            (self.xlib.XFlush)(self.display);
        }

        Ok(())
    }
}

/// Mapping between internal mouse abstraction variants and raw X11 button indexes.
static BUTTON_MAP: LazyLock<HashMap<interface::MouseButton, c_uint>> = LazyLock::new(|| {
    let mut map = HashMap::new();
    map.insert(interface::MouseButton::Left, 1);
    map.insert(interface::MouseButton::Middle, 2);
    map.insert(interface::MouseButton::Right, 3);
    map
});
