"""Main Qutebrowser configuration file."""

import typing
import themes.catppuccin as catppuccin

if "config" not in globals():
    config: typing.Any = {}

if "c" not in globals():
    c: typing.Any = {}

# Base configurations

config.load_autoconfig()

c.editor.command = ["nvim_new_win_synced", "{file}", "+{line}"]
c.fonts.hints = "15pt default_family"
c.fonts.statusbar = "12pt default_family"
c.fonts.completion.entry = "12pt default_family"
c.fonts.completion.category = "12pt default_family"

# Key binds

config.bind("<Alt-e>", "scroll-px 0 300")
config.bind("<Alt-y>", "scroll-px 0 -300")
config.bind("<Alt-d>", "scroll-page 0 0.5")
config.bind("<Alt-u>", "scroll-page 0 -0.5")

config.bind("<Alt-w>", "tab-close")
config.bind("<Alt-[>", "tab-prev")
config.bind("<Alt-]>", "tab-next")
config.bind("{", "tab-move -")
config.bind("}", "tab-move +")

config.bind('"', "cmd-set-text -s :bookmark-load")
config.bind("'", "cmd-set-text -s :quickmark-load")

# config.bind("<Shift-Tab>", "cmd-set-text -s :set-mark")
# config.bind("<Tab>", "cmd-set-text -s :jump-mark")

# Theme settings

catppuccin.set_config(c, config)
catppuccin.enable_theme("macchiato")
