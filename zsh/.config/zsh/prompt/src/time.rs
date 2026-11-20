use std::mem::MaybeUninit;
use std::time::{SystemTime, UNIX_EPOCH};

#[repr(C)]
struct Tm {
    tm_sec: i32,
    tm_min: i32,
    tm_hour: i32,
    tm_mday: i32,
    tm_mon: i32,
    tm_year: i32,
    tm_wday: i32,
    tm_yday: i32,
    tm_isdst: i32,
    tm_gmtoff: isize,
    tm_zone: *const u8,
}

unsafe extern "C" {
    fn localtime_r(timep: *const i64, result: *mut Tm) -> *mut Tm;
}

pub fn format_local_datetime() -> String {
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0);

    let mut tm = MaybeUninit::<Tm>::uninit();
    // SAFETY: `secs` and `tm` are valid pointers for `localtime_r`.
    let ptr = unsafe { localtime_r(&secs, tm.as_mut_ptr()) };
    if ptr.is_null() {
        return "0000-00-00 00:00".to_string();
    }

    // SAFETY: `localtime_r` returned non-null, so `tm` is initialized.
    let tm = unsafe { tm.assume_init() };
    format!(
        "{:04}-{:02}-{:02} {:02}:{:02}",
        tm.tm_year + 1900,
        tm.tm_mon + 1,
        tm.tm_mday,
        tm.tm_hour,
        tm.tm_min
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn formats_datetime_with_expected_shape() {
        let s = format_local_datetime();
        assert_eq!(s.len(), 16);
        assert_eq!(&s[4..5], "-");
        assert_eq!(&s[7..8], "-");
        assert_eq!(&s[10..11], " ");
        assert_eq!(&s[13..14], ":");
    }
}
