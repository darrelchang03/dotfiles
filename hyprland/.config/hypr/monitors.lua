-- Monitor configuration.
--
-- This is the single source of truth for monitor rules -- do not add
-- hl.monitor() calls to hyprland.lua as well, or the two will drift.
--
-- List connectors with: hyprctl monitors all
--
-- Identify which connector the Denon is on. Decode the EDID first rather
-- than text-searching the raw blob: `grep` is aliased to `rg` in .zshrc and
-- ripgrep skips binary files, while GNU grep reports a match only on stderr.
-- Decoding first behaves the same under grep, rg and ugrep:
--
--   for c in /sys/class/drm/card*-*/; do
--     edid-decode "$c/edid" 2>/dev/null | grep -q DENON-AVR && basename "$c"
--   done
--
-- Runtime profile switching is hyprmon's job (CTRL+SHIFT+F1..F3, see
-- hypr/bindings.lua). It applies profiles with `hyprctl keyword monitor` and
-- never writes this file, so its profiles in ~/.config/hyprmon/profiles/ must
-- be kept in step with the rules below by hand.

hl.env("GDK_SCALE", "1")

-- Catch-all fallback. Must stay FIRST: later rules override it, so any
-- monitor without an explicit rule below still comes up at its preferred
-- mode instead of staying dark.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Dell S2417DG
hl.monitor({ output = "DP-1", mode = "2560x1440@165.00", position = "0x0", scale = 1.33 })

-- Denon AVR-S760H (4K120 via HDMI 2.1 FRL)
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120.00", position = "1920x-32", scale = 1.50 })
