import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib
import subprocess

FG = "#ffffff"

CSS = f"""
.audio-lbl {{
  color: {FG};
  font-size: 12px;
}}
"""

class AudioWidget(Gtk.Button):
    def __init__(self):
        super().__init__()
        self._lbl = Gtk.Label()
        self._lbl.add_css_class("audio-lbl")
        self.set_child(self._lbl)
        self.add_css_class("flat")
        self._update()
        GLib.timeout_add(2000, self._update)
        self.connect("clicked", self._toggle)

    def _get_volume(self):
        try:
            r = subprocess.run(
                ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
                capture_output=True, text=True, timeout=2
            )
            # output: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
            parts = r.stdout.strip().split()
            vol = int(float(parts[1]) * 100)
            muted = "MUTED" in r.stdout
            return vol, muted
        except Exception:
            return 0, False

    def _update(self):
        vol, muted = self._get_volume()
        if muted:
            self._lbl.set_text("󰖁 M")
        else:
            icon = "󰕾" if vol > 50 else ("󰖀" if vol > 0 else "󰕿")
            self._lbl.set_text(f"{icon} {vol}%")
        return True

    def _toggle(self, _):
        subprocess.Popen(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        GLib.timeout_add(100, self._update)
