import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"
import Gtk4LayerShell from "gi://Gtk4LayerShell"

Gtk.init()

// ─── Bar window ──────────────────────────────────────────────────────────────

const win = new Gtk.Window({ title: "waybar" })

Gtk4LayerShell.init_for_window(win)
Gtk4LayerShell.set_layer(win, Gtk4LayerShell.Layer.TOP)
Gtk4LayerShell.set_anchor(win, Gtk4LayerShell.Edge.TOP,   true)
Gtk4LayerShell.set_anchor(win, Gtk4LayerShell.Edge.LEFT,  true)
Gtk4LayerShell.set_anchor(win, Gtk4LayerShell.Edge.RIGHT, true)
Gtk4LayerShell.auto_exclusive_zone_enable(win)

// ─── Layout ───────────────────────────────────────────────────────────────────

const bar = new Gtk.CenterBox({ hexpand: true })

const left = new Gtk.Label({ label: "my-shell", xalign: 0, hexpand: true })

const clock = new Gtk.Label({ label: "", hexpand: true })

const right = new Gtk.Label({ label: "GJS ✓", xalign: 1, hexpand: true })

bar.set_start_widget(left)
bar.set_center_widget(clock)
bar.set_end_widget(right)

win.set_child(bar)

// ─── Clock ────────────────────────────────────────────────────────────────────

function updateClock() {
  const now = GLib.DateTime.new_now_local()
  clock.set_label(now.format("%H:%M:%S"))
  return GLib.SOURCE_CONTINUE
}

updateClock()
GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, updateClock)

// ─── Run ──────────────────────────────────────────────────────────────────────

win.connect("destroy", () => loop.quit())
win.present()

const loop = GLib.MainLoop.new(null, false)
loop.run()