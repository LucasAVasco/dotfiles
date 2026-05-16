-- Official documentation: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/

hl.config({
	ecosystem = {
		enforce_permissions = true,
	},
})

hl.permission({ binary = "/usr/lib/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
