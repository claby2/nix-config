import subprocess

from libqtile import bar, hook, layout, qtile, widget
from libqtile.backend.wayland import InputConfig
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod1"
terminal = "kitty"
font = "Inter"

bg = "#000000"
bar_bg = "#212733cc"
fg = "#d9d7ce"
accent = "#ffcc66"
muted = "#686868"

gap = 12
margin = gap // 2
bar_height = 26


# The monitor (ASUS VG249QML5A on groudon) defaults to 60Hz, including when it
# is turned back on. Only set the mode when it isn't already current, since
# setting it fires screen_change again.
@hook.subscribe.startup_once
@hook.subscribe.screen_change
def set_refresh_rate(*_):
    mode = "1920x1080@240.005997Hz"
    qtile.spawn([
        "sh", "-c", f"wlr-randr | grep -q '240.005997 Hz (current' || "
        f"wlr-randr --output DP-2 --mode {mode}"
    ])


# Portals are user services that only run within graphical-session.target and
# don't inherit the environment of a session launched from a TTY. Pass the
# display along, then start qtile-session.target (hostclass/desktop.nix), which
# brings up graphical-session.target until qtile exits.
@hook.subscribe.startup_once
def start_session():
    qtile.spawn([
        "sh", "-c",
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY && "
        "systemctl --user start qtile-session.target"
    ])


@hook.subscribe.shutdown
def stop_session():
    subprocess.run(["systemctl", "--user", "stop", "qtile-session.target"])


@hook.subscribe.startup_once
def start_swayosd():
    qtile.spawn("swayosd-server")


@hook.subscribe.startup_once
def start_mako():
    top = bar_height + gap
    qtile.spawn([
        "mako",
        f"--outer-margin={top},{gap},0,{gap}",
        f"--margin=0,0,{gap},0",
    ])


# Restore the wallpaper last set with waytrogen.
@hook.subscribe.startup_once
def restore_wallpaper():
    qtile.spawn("waytrogen --restore")


# macOS-style screenshots: Cmd+Shift+3 captures the screen and Cmd+Shift+4 a
# selected region, saved to a file, or copied to the clipboard with Ctrl added.
def screenshot(region=False, clipboard=False):
    # Exit if slurp is cancelled with Escape, rather than capturing the screen.
    select = 'g=$(slurp) || exit; ' if region else ""
    geometry = '-g "$g"' if region else ""
    if clipboard:
        # Keep a temporary copy so the notification can show a thumbnail.
        cmd = (f'{select}f=$(mktemp --suffix=.png); '
               f'grim {geometry} "$f" && wl-copy --type image/png < "$f" && '
               'notify-send -i "$f" "Screenshot copied" "Copied to clipboard"')
    else:
        cmd = (f'{select}dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"; '
               'f="$dir/Screenshot $(date \'+%Y-%m-%d at %H.%M.%S\').png"; '
               f'grim {geometry} "$f" && '
               'notify-send -i "$f" "Screenshot saved" "$f"')
    return lazy.spawn(["sh", "-c", cmd])


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
    Key(["mod4", "shift"], "3", screenshot(), desc="Screenshot screen"),
    Key(["mod4", "shift"],
        "4",
        screenshot(region=True),
        desc="Screenshot region"),
    Key(["mod4", "shift", "control"],
        "3",
        screenshot(clipboard=True),
        desc="Screenshot screen to clipboard"),
    Key(["mod4", "shift", "control"],
        "4",
        screenshot(region=True, clipboard=True),
        desc="Screenshot region to clipboard"),
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


class PulseVolumeIcon(widget.PulseVolume):
    """PulseVolume showing an icon followed by the percentage.

    The built-in emoji mode shows only the icon. The icon is drawn in the Nerd
    Font, since the bar font doesn't have the glyphs.
    """

    def _update_drawer(self):
        super()._update_drawer()
        icon = f'<span font_family="JetBrainsMono Nerd Font">{self.text}</span>'
        if self.is_mute or self.volume < 0:
            self.text = icon
        else:
            self.text = f"{icon} {self.volume}%"


class Mpris2Icon(widget.Mpris2):
    """Mpris2 with a music note icon before the track.

    The icon is added after max_chars truncation so the markup isn't cut off,
    and is drawn in the Nerd Font, since the bar font doesn't have the glyph.
    """

    @property
    def formatted_text(self):
        text = super().formatted_text
        if not text:
            return text
        return f'<span font_family="JetBrainsMono Nerd Font">\U000f075a </span>{text}'


def spacer():
    """Fixed space separating groups of widgets in the bar."""
    return widget.Spacer(length=gap)


widget_defaults = dict(font=font, fontsize=14, padding=6, foreground=fg)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                spacer(),
                widget.GroupBox(
                    highlight_method="block",
                    rounded=True,
                    this_current_screen_border=accent,
                    this_screen_border=accent,
                    block_highlight_text_color=bg,
                    active=fg,
                    inactive=muted,
                    disable_drag=True,
                ),
                spacer(),
                widget.Prompt(),
                widget.WindowName(),
                Mpris2Icon(
                    format="{xesam:title} - {xesam:artist}",
                    paused_text="Paused: {track}",
                    scroll=False,
                    max_chars=50,
                ),
                spacer(),
                PulseVolumeIcon(
                    # Nerd Font volume glyphs: muted, low, medium, high.
                    emoji=True,
                    emoji_list=[
                        "\U000f075f", "\U000f057f", "\U000f0580", "\U000f057e"
                    ],
                    mute_foreground=muted,
                ),
                spacer(),
                widget.Clock(format="%a %b %-d  %-I:%M:%S %p"),
                spacer(),
            ],
            bar_height,
            background=bar_bg,
            # Flush with the screen edges; the bottom margin combines with the
            # window margin to give a full gap below the bar.
            margin=[0, 0, margin, 0],
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
