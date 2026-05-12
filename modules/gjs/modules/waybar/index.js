import Gtk from "gi://Gtk?version=4.0"
import Gtk4LayerShell from "gi://Gtk4LayerShell"

import ClockModule from "./modules/clock/index.js"
import VolumeModule from "./modules/volume/index.js"
import WifiModule from "./modules/wifi/index.js"

export default function Waybar(app) {
  const win = new Gtk.ApplicationWindow({
    application: app,
  })

  Gtk4LayerShell.init_for_window(win)

  Gtk4LayerShell.set_layer(
    win,
    Gtk4LayerShell.Layer.TOP
  )

  Gtk4LayerShell.set_anchor(
    win,
    Gtk4LayerShell.Edge.TOP,
    true
  )

  Gtk4LayerShell.set_anchor(
    win,
    Gtk4LayerShell.Edge.LEFT,
    true
  )

  Gtk4LayerShell.set_anchor(
    win,
    Gtk4LayerShell.Edge.RIGHT,
    true
  )

  Gtk4LayerShell.auto_exclusive_zone_enable(win)

  const bar = new Gtk.CenterBox({
    hexpand: true,
    margin_top: 6,
    margin_bottom: 6,
    margin_start: 12,
    margin_end: 12,
  })

  // LEFT
  const left = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 10,
    hexpand: true,
  })

  left.append(
    new Gtk.Label({
      label: "my-shell",
    })
  )

  // CENTER
  const center = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 10,
    halign: Gtk.Align.CENTER,
  })

  center.append(ClockModule())

  // RIGHT
  const right = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 10,
    hexpand: true,
    halign: Gtk.Align.END,
  })

  right.append(VolumeModule())
  right.append(WifiModule())

  bar.set_start_widget(left)
  bar.set_center_widget(center)
  bar.set_end_widget(right)

  win.set_child(bar)

  win.present()
}