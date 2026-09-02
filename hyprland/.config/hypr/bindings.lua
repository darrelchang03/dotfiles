-- Personal keybinding overrides, migrated from the old bindings.conf.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print
--
-- Bindings that match an Omarchy default were dropped rather than restated
-- (Tmux, Browser, File manager, Docker). Where a personal binding collides
-- with a default, the default is unbound first and the comment says what it
-- used to do.

-- ---------------------------------------------------------------------------
-- Terminal
-- ---------------------------------------------------------------------------

-- Was: Terminal, opening in the active terminal's cwd. Always start in $HOME.
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", [[setsid uwsm-app -- xdg-terminal-exec --dir="$HOME"]])

-- ---------------------------------------------------------------------------
-- Applications
-- ---------------------------------------------------------------------------

o.bind("SUPER + B", "Browser", { omarchy = "browser" })

-- Was: Browser. Make the shifted variant open a private window.
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })

o.bind("SUPER + M", "Music", { launch = "spotify-launcher", focus = "spotify" })
o.bind("SUPER + D", "Discord", { launch = "discord", focus = "discord" })

o.bind("SUPER + ALT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

-- ---------------------------------------------------------------------------
-- Web apps
-- ---------------------------------------------------------------------------

-- o.bind("SUPER + A", "ChatGPT", { webapp = "https://chatgpt.com?temporary-chat=true" })
-- o.bind("SUPER + ALT + A", "Grok", { webapp = "https://grok.com" })
-- o.bind("SUPER + E", "Email", { webapp = "https://gmail.com" })
-- o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/", focus = true })

-- o.bind("SUPER + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })

-- ---------------------------------------------------------------------------
-- Utilities
-- ---------------------------------------------------------------------------

-- Was: Google Maps.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Configure sunsetr", [[omarchy-launch-tui nvim "$HOME/.config/sunsetr/sunsetr.toml"]])

-- Was: Signal. Gaming Mode takes the key, so Signal has no binding left;
-- give it a free key here if you want one back.
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "Gaming Mode", "/usr/local/bin/switch-to-gaming")

-- Was: Omarchy's nightlight toggle, which spawns hyprsunset and would fight
-- sunsetr over gamma control. Toggles sunsetr's "day" preset instead.
hl.unbind("SUPER + CTRL + N")
o.bind("SUPER + CTRL + N", "Toggle nightlight", [[$HOME/.local/scripts/toggle-nightlight.sh]])

-- ---------------------------------------------------------------------------
-- Monitor profiles (hyprmon)
-- ---------------------------------------------------------------------------

o.bind("CTRL + SHIFT + F1", "Hyprmon Just Monitor", [[hyprmon --profile "Just Monitor"]])
o.bind("CTRL + SHIFT + F2", "Hyprmon Just TV", [[hyprmon --profile "Just TV"]])
o.bind("CTRL + SHIFT + F3", "Hyprmon With TV", [[hyprmon --profile "With TV"]])

-- Kick the Denon back into sync when the TV comes up black. The connector is
-- pinned on (drm.edid_firmware + video=HDMI-A-1:e), so the GPU never sees the
-- receiver leave and never re-modesets when it returns; this forces one.
-- Normally denon-audio-follow does it automatically, but only while the AVR is
-- reachable on the network.
o.bind("CTRL + SHIFT + F4", "Denon Re-Modeset", [[denon-audio-follow --bounce]])

-- ---------------------------------------------------------------------------
-- Forward page up/down to Discord
-- ---------------------------------------------------------------------------

o.bind("Page_Up", nil, [[$HOME/.dotfiles/bin/.local/scripts/send_to_electron.sh ",page_up" class discord]])
o.bind("Page_Down", nil, [[$HOME/.dotfiles/bin/.local/scripts/send_to_electron.sh ",page_down" class discord]])


o.bind("SUPER + SHIFT + L", "Lock screen explorer", "omarchy-shell lock explore")

o.bind("SUPER + CTRL + D", "Look up selection in dictionary", "omarchy-dictionary-lookup")
