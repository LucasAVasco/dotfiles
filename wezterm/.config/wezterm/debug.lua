local wezterm = require('wezterm')

---@class DegugUtil Debug utility available in all WezTerm scripts. Use 'ShowDebugOverlay' to show all debug logs
---@field info fun(msg: any) Logs info message
---@field warn fun(msg: any) Logs warning message
---@field error fun(msg: any) Logs error message
DEBUG = {}
DEBUG.info = wezterm.log_info
DEBUG.warn = wezterm.log_warn
DEBUG.error = wezterm.log_error
