-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║           hyprland.lua — archruud — Medion Erazer X10                   ║
-- ║           Konvertert fra hyprland.conf til Lua (Hyprland 0.55+)         ║
-- ║           Fil: ~/.config/hypr/hyprland.lua                              ║
-- ║           Ref: https://wiki.hypr.land/Configuring/Start/                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

--────────────────────────────────────────────────────────────────────────────
-- MONITOR
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
--────────────────────────────────────────────────────────────────────────────

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200@165",
    position = "0x0",
    scale    = 1,
})

--────────────────────────────────────────────────────────────────────────────
-- PROGRAMMER (variabler)
-- https://wiki.hypr.land/Configuring/Keywords/
--────────────────────────────────────────────────────────────────────────────

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = os.getenv("HOME") .. "/.config/rofi/launchers/type-3/launcher.sh"
local mainMod     = "SUPER"

--────────────────────────────────────────────────────────────────────────────
-- AUTOSTART
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Alle exec-once samles i én hyprland.start-event
--────────────────────────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/awww-wallpaper.sh")
    hl.exec_cmd("sleep 1 && waybar")        -- sleep 1: waybar timing-fix for 0.55
    hl.exec_cmd("dunst")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("qs -c overview")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dropterminal-init.sh")
end)

--────────────────────────────────────────────────────────────────────────────
-- ENVIRONMENT VARIABLES
-- NB: Bruk ~/.config/uwsm/env for GTK/Qt/xcursor om du bruker uwsm
-- https://wiki.hypr.land/Configuring/Environment-variables/
--────────────────────────────────────────────────────────────────────────────

hl.env("XCURSOR_SIZE",   "24")
hl.env("HYPRCURSOR_SIZE","24")
hl.env("XDG_MENU_PREFIX","arch-")

--────────────────────────────────────────────────────────────────────────────
-- UTSEENDE OG FØLELSE (Look and Feel)
-- https://wiki.hypr.land/Configuring/Variables/
--────────────────────────────────────────────────────────────────────────────

hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 6,
        border_size      = 2,
        ["col.active_border"]   = "rgba(33ccffee) rgba(00ff99ee) 45deg",
        ["col.inactive_border"] = "rgba(595959aa)",
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 15,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    -- Dwindle layout
    -- NB: pseudotile fjernet i 0.55 — bare preserve_split igjen
    dwindle = {
        preserve_split = true,
    },

    -- Master layout (ikke i bruk, men beholdt)
    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
    },

    input = {
        kb_layout  = "no",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
        },
    },

    cursor = {
        no_warps = true,
    },
})

--────────────────────────────────────────────────────────────────────────────
-- GESTURES (3-finger sveip for workspace-bytte)
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
--────────────────────────────────────────────────────────────────────────────

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

--────────────────────────────────────────────────────────────────────────────
-- ANIMASJONER
-- https://wiki.hypr.land/Configuring/Animations/
--────────────────────────────────────────────────────────────────────────────

-- Bezier-kurver
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Animasjoner
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"       })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint"  })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint"  })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear"  })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"         })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint"  })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear"  })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"  })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick"         })

--────────────────────────────────────────────────────────────────────────────
-- DEVICE-CONFIG (mus)
--────────────────────────────────────────────────────────────────────────────

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

--────────────────────────────────────────────────────────────────────────────
-- KEYBINDINGS
-- https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Oversettelsesguide:
--   bind   → hl.bind(...)
--   binde  → hl.bind(..., { repeating = true })
--   bindm  → hl.bind(...) med mouse:272 / mouse:273
--   bindel → hl.bind(..., { locked = true, repeating = true })
--   bindl  → hl.bind(..., { locked = true })
--────────────────────────────────────────────────────────────────────────────

-- Standard binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + A",      hl.dsp.exec_cmd("killall rofi || " .. menu))
hl.bind(mainMod .. " + J",      hl.dsp.layout_msg("togglesplit"))       -- dwindle (erstatter togglesplit)
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())

-- Mine egne binds
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd('firefox --new-window "https://www.google.no"'))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("zeditor " .. os.getenv("HOME") .. "/"))
hl.bind("XF86PowerOff",    hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + TAB",      hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill -SIGUSR2 waybar 2>/dev/null || (pkill waybar; nohup waybar &)"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/fuzzel-hyprpicker.sh"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd('cliphist list | rofi -dmenu -theme ~/.config/rofi/clipboard.rasi -p "Clipboard" | cliphist decode | wl-copy'))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/fuzzel-nettapper &"))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/hint.sh"))

-- Skjermdump
hl.bind(mainMod .. " SHIFT + S",   hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(mainMod .. " CTRL + S",    hl.dsp.exec_cmd('sh -c "grim - | swappy -f -"'))
hl.bind(mainMod .. " ALT + S",     hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/screenshot-window.sh"))

-- Dropdown Terminal
hl.bind(mainMod .. " SHIFT + RETURN", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dropterminal.sh kitty"))

-- Volum med notifikasjoner (egne scripts)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/volume-notify.sh up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/volume-notify.sh down"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/volume-notify.sh mute"))

-- Lysstyrke med notifikasjoner (egne scripts)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/brightness-notify.sh up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/brightness-notify.sh down"))

-- Fokus med piltaster
hl.bind(mainMod .. " + left",  hl.dsp.window.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.window.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.window.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.window.focus({ direction = "d" }))

-- Bytt workspace (1-10)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.workspace.change(i))
    hl.bind(mainMod .. " SHIFT + " .. i, hl.dsp.workspace.move_window(i))
end
hl.bind(mainMod .. " + 0",       hl.dsp.workspace.change(10))
hl.bind(mainMod .. " SHIFT + 0", hl.dsp.workspace.move_window(10))

-- Scroll gjennom workspaces med musehjul
hl.bind(mainMod .. " + mouse_down", hl.dsp.workspace.change("e+1"))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.workspace.change("e-1"))

-- Flytt/resize vindu med mus (bindm)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.move())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Multimedia — volum (bindel: locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                     { locked = true, repeating = true })

-- Media-kontroll (bindl: locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Resize aktivt vindu (binde: repeating)
hl.bind(mainMod .. " ALT + left",  hl.dsp.window.resize({ x = -50, y = 0   }), { repeating = true }) -- Smalere
hl.bind(mainMod .. " ALT + right", hl.dsp.window.resize({ x =  50, y = 0   }), { repeating = true }) -- Bredere
hl.bind(mainMod .. " ALT + up",    hl.dsp.window.resize({ x = 0,   y = -50 }), { repeating = true }) -- Lavere
hl.bind(mainMod .. " ALT + down",  hl.dsp.window.resize({ x = 0,   y =  50 }), { repeating = true }) -- Høyere

-- Dropdown Terminal resize (binde: repeating)
hl.bind(mainMod .. " SHIFT + left",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dropterminal-resize.sh left"),  { repeating = true })
hl.bind(mainMod .. " SHIFT + right", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dropterminal-resize.sh right"), { repeating = true })
hl.bind(mainMod .. " SHIFT + up",    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dropterminal-resize.sh up"),    { repeating = true })
hl.bind(mainMod .. " SHIFT + down",  hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/dropterminal-resize.sh down"),  { repeating = true })

--────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- NB: Lua bruker % som escape i patterns (ikke \)
--────────────────────────────────────────────────────────────────────────────

-- WiFi / Network Manager (nmgui)
hl.window_rule({
    match     = { class = "^(com%.network%.manager)$" },
    float     = true,
    size      = { width = 450, height = 600 },
    center    = true,
    animation = "slide",
})

-- Bluetooth (blueman-manager)
hl.window_rule({
    match     = { class = "^(blueman%-manager)$" },
    float     = true,
    size      = { width = 600, height = 700 },
    center    = true,
    animation = "slide",
})

-- Lyd & Mikrofon (pavucontrol)
hl.window_rule({
    match     = { class = "^(org%.pulseaudio%.pavucontrol)$" },
    float     = true,
    size      = { width = 800, height = 900 },
    center    = true,
    animation = "slide",
})

-- Gesture er nå lagt inn med hl.gesture() — se GESTURES-seksjonen over.
