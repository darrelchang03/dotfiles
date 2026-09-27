-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Network manager tray applet.
o.exec_on_start("nm-applet --indicator")

-- Auto nightlight.
o.exec_on_start("sunsetr")

-- Sunshine (Moonlight host). Idempotent: enables the unit on a fresh machine
-- and starts it this session. The unit is WantedBy=graphical-session.target,
-- so it follows the desktop session -- no linger needed.
-- o.exec_on_start("systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service")
