from libqtile import bar, hook, layout, qtile, widget
from libqtile.backend.wayland import InputConfig
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod1"
terminal = "kitty"
font = "JetBrainsMono Nerd Font"

bg = "#000000"
fg = "#d9d7ce"
accent = "#ffcc66"
muted = "#686868"

gap = 10
margin = gap // 2
bar_height = 26


# Set the refresh rate on startup.
# The monitor (ASUS VG249QML5A on groudon) defaults to 60Hz.
@hook.subscribe.startup_once
def set_refresh_rate():
    qtile.spawn(
        ["wlr-randr", "--output", "DP-2", "--mode", "1920x1080@240.005997Hz"])


@hook.subscribe.startup_once
def start_swayosd():
    qtile.spawn("swayosd-server")


@hook.subscribe.startup_once
def start_mako():
    top = gap + bar_height + gap
    qtile.spawn([
        "mako",
        f"--outer-margin={top},{gap},0,{gap}",
        f"--margin=0,0,{gap},0",
    ])


keys = [
    Key([mod], "h", lazy.layout.left(), desc="Move focus left"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus right"),
    Key([mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        desc="Move window left"),
    Key([mod, "shift"],
        "j",
        lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window right"),
    Key([mod, "shift"],
        "space",
        lazy.window.toggle_floating(),
        desc="Toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    # Closest thing to rift's toggle_space_activated: flip the workspace
    # between tiling and floating.
    Key([mod], "z", lazy.next_layout(),
        desc="Toggle tiling on this workspace"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Not in rift (macOS handles these), but needed here.
    # Super stands in for Cmd, matching Cmd+Q on macOS.
    Key(["mod4"], "q", lazy.window.kill(), desc="Close window"),
    Key(["mod4"], "space", lazy.spawn("fuzzel"),
        desc="Search and launch apps"),
    Key([mod], "d", lazy.spawncmd(), desc="Run a command"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload config"),
    Key([mod, "shift"], "e", lazy.shutdown(), desc="Quit qtile"),
    Key([],
        "XF86AudioRaiseVolume",
        lazy.spawn("swayosd-client --output-volume raise"),
        desc="Raise volume"),
    Key([],
        "XF86AudioLowerVolume",
        lazy.spawn("swayosd-client --output-volume lower"),
        desc="Lower volume"),
    Key([],
        "XF86AudioMute",
        lazy.spawn("swayosd-client --output-volume mute-toggle"),
        desc="Toggle mute"),
]

# Ctrl+Alt+Fn switches VTs on Wayland.
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(
                func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        ))

groups = [Group(i) for i in "123456789"]

for g in groups:
    keys.extend([
        Key([mod],
            g.name,
            lazy.group[g.name].toscreen(),
            desc=f"Switch to workspace {g.name}"),
        Key([mod, "shift"],
            g.name,
            lazy.window.togroup(g.name),
            desc=f"Move window to workspace {g.name}"),
    ])

border = dict(border_focus=accent, border_normal=bg, border_width=2)

layouts = [
    layout.Columns(
        **border,
        margin=margin,
        margin_on_single=margin,
        border_on_single=True,
        # Stop focus at the screen edge instead of wrapping to the other side.
        wrap_focus_columns=False,
        wrap_focus_rows=False,
        wrap_focus_stacks=False,
    ),
    layout.Floating(**border),
]

floating_layout = layout.Floating(
    **border,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="pinentry"),
    ],
)

widget_defaults = dict(font=font, fontsize=13, padding=6, foreground=fg)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    highlight_method="text",
                    this_current_screen_border=accent,
                    active=fg,
                    inactive=muted,
                    disable_drag=True,
                ),
                widget.Prompt(),
                widget.WindowName(),
                widget.Clock(format="%a %b %-d  %H:%M"),
            ],
            bar_height,
            background=bg,
            # [top, right, bottom, left]; the bottom combines with the window
            # margin to give a full gap below the bar.
            margin=[gap, gap, margin, gap],
        ),
        bottom=bar.Gap(margin),
        left=bar.Gap(margin),
        right=bar.Gap(margin),
        background=bg,
    ),
]

mouse = [
    Drag([mod],
         "Button1",
         lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod],
         "Button3",
         lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = True
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
# Faster than the defaults (25/s after 600ms), closer to macOS.
wl_input_rules = {
    "type:keyboard": InputConfig(kb_repeat_rate=50, kb_repeat_delay=250),
    "type:pointer": InputConfig(natural_scroll=True),
}
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
