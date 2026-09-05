import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib
import subprocess

FG = "#ffffff"

CSS = f"""
.net-lbl {{
  color: {FG};
  font-size: 12px;
}}
"""

class NetworkWidget(Gtk.Label):
    def __init__(self):
        super().__init__()
        self.add_css_class("net-lbl")
        self._update()
        GLib.timeout_add(5000, self._update)

    def _update(self):
        try:
            r = subprocess.run(
                ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"],
                capture_output=True, text=True, timeout=3
            )
            connected = False
            wifi_name = ""
            for line in r.stdout.strip().splitlines():
                parts = line.split(":")
                if len(parts) >= 3 and parts[1] == "connected":
                    connected = True
                    if parts[0] == "wifi":
                        wifi_name = parts[2]
                        break
                    elif parts[0] == "ethernet":
                        wifi_name = "eth"
                        break
            if connected and wifi_name:
                self.set_text(f"󰤨 {wifi_name[:12]}")
            elif connected:
                self.set_text("󰤨")
            else:
                self.set_text("󰤭")
        except Exception:
            self.set_text("󰤭")
        return True
