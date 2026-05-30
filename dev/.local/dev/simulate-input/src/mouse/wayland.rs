use anyhow::{Context, Result};
use std::collections::HashMap;
use std::sync::LazyLock;
use std::time::Duration;
use wayland_client::protocol::wl_pointer::{Axis, ButtonState};
use wayland_client::protocol::{wl_registry, wl_seat};
use wayland_client::{Connection, Dispatch, Proxy, QueueHandle};
use wayland_protocols_wlr::virtual_pointer::v1::client::{
    zwlr_virtual_pointer_manager_v1::ZwlrVirtualPointerManagerV1,
    zwlr_virtual_pointer_v1::ZwlrVirtualPointerV1,
};

use crate::mouse::interface;

/// A mouse simulator that targets Wayland compositors supporting the `virtual_pointer_v1` protocol.
pub struct MouseSimulator {
    event_queue: wayland_client::EventQueue<AppState>,
    virtual_pointer: ZwlrVirtualPointerV1,
}

impl MouseSimulator {
    /// Connects to the Wayland compositor and initializes a virtual pointer.
    ///
    /// This process involves connecting to the environment, discovering the virtual pointer
    /// manager and the seat via the registry, and then creating the virtual pointer.
    pub fn new() -> Result<Self> {
        // Connect to the compositor environment
        let conn = Connection::connect_to_env()?;
        let mut event_queue = conn.new_event_queue();
        let queue_handle = event_queue.handle();

        let mut state = AppState::new();

        // Trigger initial roundtrip to discover seats and managers
        let _registry = conn.display().get_registry(&queue_handle, ());
        event_queue
            .roundtrip(&mut state)
            .context("failed to roundtrip event queue")?;

        let manager = state
            .pointer_manager
            .as_ref()
            .cloned()
            .context("compositor did not broadcast a valid global virtual pointer manager")?;

        let seat = state
            .seat
            .as_ref()
            .cloned()
            .context("compositor did not broadcast a valid wl_seat global")?;

        // Instantiate our hardware-emulating virtual pointer device
        let virtual_pointer = manager.create_virtual_pointer(Some(&seat), &queue_handle, ());

        // Trigger roundtrip to create the virtual pointer
        event_queue
            .roundtrip(&mut state)
            .context("failed to roundtrip event queue")?;

        Ok(MouseSimulator {
            event_queue,
            virtual_pointer,
        })
    }

    /// Flushes the event queue and blocks until all pending events are processed.
    pub fn flush_sync(&mut self) -> Result<()> {
        // Send pending events
        self.event_queue
            .flush()
            .context("failed to flush event queue")?;

        // Block until all pending events have been processed
        let mut dummy_state = AppState::new();

        self.event_queue
            .roundtrip(&mut dummy_state)
            .context("failed to roundtrip display")?;
        Ok(())
    }

    /// Internal helper to handle axis-based scrolling.
    fn scroll_to_direction(self: &mut MouseSimulator, axis: Axis, distance: i32) -> Result<()> {
        if distance == 0 {
            return Ok(());
        }

        // Get current time in milliseconds relative to application start
        static START_TIME: std::sync::OnceLock<std::time::Instant> = std::sync::OnceLock::new();
        let start = START_TIME.get_or_init(std::time::Instant::now);
        let time = start.elapsed().as_millis() as u32;

        // Send axis event
        self.virtual_pointer.axis(time, axis, distance as f64);

        // Set axis source to Finger for common compatibility
        self.virtual_pointer
            .axis_source(wayland_client::protocol::wl_pointer::AxisSource::Finger);

        // End the frame to commit the event
        self.virtual_pointer.frame();

        Ok(())
    }
}

impl interface::Simulator for MouseSimulator {
    /// Simulates a mouse button click on Wayland.
    ///
    /// It sends a Pressed event, sleeps briefly, and then sends a Released event.
    fn click(&mut self, button: interface::MouseButton) -> Result<()> {
        let button_code = BUTTON_MAP.get(&button).context("unknown mouse button")?;

        // Send Pressed frame
        self.virtual_pointer
            .button(0, *button_code, ButtonState::Pressed);
        self.virtual_pointer.frame();
        self.event_queue.flush()?;

        // Brief mechanical delay to ensure downstream applications register a valid click duration
        std::thread::sleep(Duration::from_millis(50));

        // Send Released frame
        self.virtual_pointer
            .button(0, *button_code, ButtonState::Released);
        self.virtual_pointer.frame();
        self.event_queue.flush()?;

        Ok(())
    }

    /// Simulates mouse wheel scrolling on Wayland.
    fn scroll(&mut self, dx: i32, dy: i32) -> Result<()> {
        if dx != 0 {
            self.scroll_to_direction(Axis::HorizontalScroll, dx)
                .context("failed to scroll horizontally")?;
        }
        if dy != 0 {
            self.scroll_to_direction(Axis::VerticalScroll, dy)
                .context("failed to scroll vertically")?;
        }

        self.flush_sync().context("failed to flush sync")?;

        Ok(())
    }
}

/// Mapping between internal mouse abstraction variants and Wayland button codes.
static BUTTON_MAP: LazyLock<HashMap<interface::MouseButton, u32>> = LazyLock::new(|| {
    let mut map = HashMap::new();
    map.insert(interface::MouseButton::Left, 272);
    map.insert(interface::MouseButton::Right, 273);
    map.insert(interface::MouseButton::Middle, 274);
    map
});

/// Application state used during the Wayland registry discovery phase.
struct AppState {
    pointer_manager: Option<ZwlrVirtualPointerManagerV1>,
    seat: Option<wl_seat::WlSeat>,
}

impl AppState {
    fn new() -> Self {
        Self {
            pointer_manager: None,
            seat: None,
        }
    }
}

/// Handles registry events to discover and bind necessary Wayland globals.
impl Dispatch<wl_registry::WlRegistry, ()> for AppState {
    fn event(
        state: &mut Self,
        registry: &wl_registry::WlRegistry,
        event: wl_registry::Event,
        _data: &(),
        _conn: &Connection,
        queue_handle: &QueueHandle<Self>,
    ) {
        if let wl_registry::Event::Global {
            name,
            interface,
            version,
        } = event
        {
            if interface == wayland_protocols_wlr::virtual_pointer::v1::client::__interfaces::ZWLR_VIRTUAL_POINTER_MANAGER_V1_INTERFACE.name {
                let manager = registry.bind::<ZwlrVirtualPointerManagerV1, _, _>(
                    name,
                    2, // Bind using protocol version 2
                    queue_handle,
                    (),
                );
                state.pointer_manager = Some(manager);
            }

            else if interface == wayland_client::protocol::__interfaces::WL_SEAT_INTERFACE.name {
                let seat = registry.bind::<wl_seat::WlSeat, _, _>(
                    name,
                    version,
                    queue_handle,
                    (),
                );
                state.seat = Some(seat);
            }
        }
    }
}

/// Boilerplate implementation for the virtual pointer manager.
impl Dispatch<ZwlrVirtualPointerManagerV1, ()> for AppState {
    fn event(
        _state: &mut Self,
        _proxy: &ZwlrVirtualPointerManagerV1,
        _event: <ZwlrVirtualPointerManagerV1 as Proxy>::Event,
        _data: &(),
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
    ) {
        // The manager interface itself issues no events
    }
}

/// Boilerplate implementation for the virtual pointer.
impl Dispatch<ZwlrVirtualPointerPointer, ()> for AppState {
    fn event(
        _state: &mut Self,
        _proxy: &ZwlrVirtualPointerV1,
        _event: <ZwlrVirtualPointerV1 as Proxy>::Event,
        _data: &(),
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
    ) {
    }
}

/// Alias required due to wayland-client naming conventions on generated bindings.
type ZwlrVirtualPointerPointer = ZwlrVirtualPointerV1;

/// Boilerplate implementation for the seat interface.
impl Dispatch<wl_seat::WlSeat, ()> for AppState {
    fn event(
        _state: &mut Self,
        _seat: &wl_seat::WlSeat,
        _event: wl_seat::Event,
        _data: &(),
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
    ) {
        // We do not need to listen to seat capabilities for this simple context
    }
}
