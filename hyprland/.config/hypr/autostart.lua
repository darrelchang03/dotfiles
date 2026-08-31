-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Network manager tray applet.
o.exec_on_start("nm-applet --indicator")

-- Auto nightlight.
o.exec_on_start("sunsetr")
