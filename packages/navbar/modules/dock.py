import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

BG = "#111827"
FG = "#ffffff"

CSS = f"""
.dock-box {{
  background: {BG};
  border-radius: 12px;
  padding: 4px 10px;
}}
.dock-btn {{
  background: transparent;
  border: none;
  border-radius: 8px;
  padding: 4px;
  min-width: 32px;
  min-height: 32px;
}}
.dock-btn:hover {{
  background: rgba(255,255,255,0.1);
}}
"""

DOCK_ITEMS = [
    ("visual-studio-code", "VSCode"),
    ("firefox",            "Firefox"),
]

class DockWidget(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.add_css_class("dock-box")
        for icon_name, tooltip in DOCK_ITEMS:
            btn = Gtk.Button()
            btn.add_css_class("dock-btn")
            btn.set_tooltip_text(tooltip)
            img = Gtk.Image.new_from_icon_name(icon_name)
            img.set_pixel_size(22)
            btn.set_child(img)
            # placeholder — no action yet
            btn.connect("clicked", lambda _b: None)
            self.append(btn)
