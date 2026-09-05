import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib
import psutil

FG = "#ffffff"
BG = "#111827"

CSS = f"""
.sysinfo-lbl {{
  color: {FG};
  font-size: 12px;
}}
"""

class SysinfoWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self._cpu_lbl = Gtk.Label()
        self._ram_lbl = Gtk.Label()
        for lbl in (self._cpu_lbl, self._ram_lbl):
            lbl.add_css_class("sysinfo-lbl")
            self.append(lbl)
        self._update()
        GLib.timeout_add(2000, self._update)

    def _update(self):
        cpu = psutil.cpu_percent(interval=None)
        ram = psutil.virtual_memory()
        self._cpu_lbl.set_text(f" {cpu:.0f}%")
        used_gb = ram.used / 1024**3
        total_gb = ram.total / 1024**3
        self._ram_lbl.set_text(f" {used_gb:.1f}/{total_gb:.0f}G")
        return True
