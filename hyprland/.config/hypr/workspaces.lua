-- Workspace layout: workspaces 1-9 live on the main monitor, 11-19 on the
-- secondary, and each monitor gets its own number row.
--
-- Find monitor names with: hyprctl monitors

local main = "DP-1"
local second = "HDMI-A-1"

-- Omarchy binds SUPER + 1..0 to workspaces 1-10 and SUPER + SHIFT + 1..0 to
-- moving windows there. Drop both rows first: SUPER is reused below for the
-- secondary monitor. code:10-19 is the number row, 1 through 0.
for code = 10, 19 do
  hl.unbind("SUPER + code:" .. code)
  hl.unbind("SUPER + SHIFT + code:" .. code)
end

-- Pin workspace IDs to monitors.
for ws = 1, 9 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = main, default_name = tostring(ws) })
end

for ws = 11, 19 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = second, default_name = tostring(ws) })
end

-- Main monitor: ALT + number switches, ALT + SHIFT + number moves the window.
for n = 1, 9 do
  local ws = tostring(n)

  o.bind("ALT + " .. n, "Switch to workspace " .. n, hl.dsp.focus({ workspace = ws }))
  o.bind("ALT + SHIFT + " .. n, "Move to workspace " .. n, hl.dsp.window.move({ workspace = ws }))
end

-- Secondary monitor: SUPER + number reaches workspaces 11-19, so the same
-- physical key means "workspace N" on whichever monitor the modifier picks.
for n = 1, 9 do
  local ws = tostring(n + 10)

  o.bind("SUPER + " .. n, "Switch to workspace " .. n .. " (secondary)", hl.dsp.focus({ workspace = ws }))
  o.bind("SUPER + SHIFT + " .. n, "Move to workspace " .. n .. " (secondary)", hl.dsp.window.move({ workspace = ws }))
end

-- Start on the main monitor's workspace 1, with the secondary showing 11.
-- The old exec-once shelled out to `hyprctl dispatch`, which Hyprland 0.56
-- rejects under its Lua dispatch syntax; dispatch natively instead.
hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.focus({ monitor = second }))
  hl.dispatch(hl.dsp.focus({ workspace = "11" }))
  hl.dispatch(hl.dsp.focus({ monitor = main }))
  hl.dispatch(hl.dsp.focus({ workspace = "1" }))
end)
