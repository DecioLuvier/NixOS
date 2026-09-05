#!/usr/bin/env python3
"""GTK4 navbar for Hyprland — single layer-shell window with 3 sections."""

import gi
gi.require_version("Gtk",           "4.0")
gi.require_version("Gdk",           "4.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GLib, GtkLayerShell

import sys, os
sys.path.insert(0, os.path.dirname(__file__))

from modules.workspaces import WorkspacesWidget, load_css as ws_css
from modules.dock       import DockWidget
from modules.sysinfo    import SysinfoWidget
from modules.audio      import AudioWidget
from modules.network    import NetworkWidget
from modules.clock      import ClockWidget

BG     = "#111827"
ACCENT = "#025939"
FG     = "#ffffff"

GLOBAL_CSS = f"""
window {{
  background: transparent;
}}
.bar-root {{
  background: transparent;
}}
.bar-pill {{
  background: {BG};
  border-radius: 12px;
  padding: 4px 10px;
  margin: 2px 4px;
  color: {FG};
}}
.bar-pill label {{
  color: {FG};
  font-size: 12px;
}}
"""

def apply_global_css():
    provider = Gtk.CssProvider()
    provider.load_from_string(GLOBAL_CSS)
    display = Gdk.Display.get_default()
    Gtk.StyleContext.add_provider_for_display(
        display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

def make_window(app: Gtk.Application) -> Gtk.Window:
    win = Gtk.ApplicationWindow(application=app)
    win.set_decorated(False)

    GtkLayerShell.init_for_window(win)
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.TOP)
    GtkLayerShell.auto_exclusive_zone_enable(win)
    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.BOTTOM, 4)
    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.LEFT,   8)
    GtkLayerShell.set_margin(win, GtkLayerShell.Edge.RIGHT,  8)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.BOTTOM, True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.LEFT,   True)
    GtkLayerShell.set_anchor(win, GtkLayerShell.Edge.RIGHT,  True)

    return win

def on_activate(app: Gtk.Application):
    apply_global_css()

    win = make_window(app)

    # Root horizontal box — full width
    root = Gtk.CenterBox()
    root.add_css_class("bar-root")
    win.set_child(root)

    # ── LEFT: workspaces ──────────────────────────────────────────────────
    left = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
    ws = WorkspacesWidget()
    left.append(ws)
    root.set_start_widget(left)

    # ── CENTRE: dock ──────────────────────────────────────────────────────
    centre = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
    dock = DockWidget()
    centre.append(dock)
    root.set_center_widget(centre)

    # ── RIGHT: sysinfo + audio + network + clock ───────────────────────
    right = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
    right.add_css_class("bar-pill")

    sys_box = SysinfoWidget()
    audio   = AudioWidget()
    net     = NetworkWidget()
    clock   = ClockWidget()

    sep = lambda: Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
    for w in (sys_box, sep(), audio, sep(), net, sep(), clock):
        right.append(w)

    root.set_end_widget(right)

    win.present()

def main():
    app = Gtk.Application(application_id="com.luvier.navbar")
    app.connect("activate", on_activate)
    app.run(None)

if __name__ == "__main__":
    main()
