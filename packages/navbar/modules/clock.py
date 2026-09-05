import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib
from datetime import datetime

FG = "#ffffff"

CSS = f"""
.clock-lbl {{
  color: {FG};
  font-size: 13px;
  font-weight: bold;
}}
"""

class ClockWidget(Gtk.Label):
    def __init__(self):
        super().__init__()
        self.add_css_class("clock-lbl")
        self._update()
        GLib.timeout_add(10000, self._update)

    def _update(self):
        now = datetime.now()
        self.set_text(now.strftime("%H:%M"))
        return True
