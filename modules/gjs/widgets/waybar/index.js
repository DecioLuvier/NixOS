import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"
import Gtk4LayerShell from "gi://Gtk4LayerShell"

export default function Waybar(app) {
  const win = new Gtk.ApplicationWindow({
    application: app,
  })

  // Layer shell
  Gtk4LayerShell.init_for_window(win)
  Gtk4LayerShell.set_layer(win, Gtk4LayerShell.Layer.TOP)

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

  // Layout principal
  const bar = new Gtk.CenterBox({
    hexpand: true,
    margin_top: 6,
    margin_bottom: 6,
    margin_start: 12,
    margin_end: 12,
  })

  // LEFT
  const left = new Gtk.Label({
    label: "my-shell",
    xalign: 0,
    hexpand: true,
  })

  // CENTER
  const clock = new Gtk.Label({
    label: "",
    hexpand: true,
  })

  // RIGHT
  const rightBox = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 10,
    hexpand: true,
    halign: Gtk.Align.END,
  })

  // =========================
  // WIFI BUTTON
  // =========================

  const wifiButton = new Gtk.MenuButton({
    icon_name:
      "network-wireless-signal-excellent-symbolic",
  })

  const popover = new Gtk.Popover()

  const popBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 8,
    margin_top: 12,
    margin_bottom: 12,
    margin_start: 12,
    margin_end: 12,
    width_request: 300,
  })

  // Header
  const header = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 8,
  })

  const title = new Gtk.Label({
    label: "Wi-Fi",
    xalign: 0,
    hexpand: true,
  })

  const toggle = new Gtk.Switch({
    active: true,
  })

  header.append(title)
  header.append(toggle)

  const separator = new Gtk.Separator({
    orientation: Gtk.Orientation.HORIZONTAL,
  })

  // Networks
  const networks = [
    "MinhaCasa_5G",
    "Starlink",
    "Cafe_Wifi",
    "NET_2G",
  ]

  const list = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 6,
  })

  for (const network of networks) {
    const btn = new Gtk.Button()

    const row = new Gtk.Box({
      orientation: Gtk.Orientation.HORIZONTAL,
      spacing: 8,
      margin_top: 6,
      margin_bottom: 6,
      margin_start: 6,
      margin_end: 6,
    })

    const icon = new Gtk.Image({
      icon_name:
        "network-wireless-signal-excellent-symbolic",
    })

    const label = new Gtk.Label({
      label: network,
      xalign: 0,
      hexpand: true,
    })

    row.append(icon)
    row.append(label)

    btn.set_child(row)

    btn.connect("clicked", () => {
      print(`Connecting to ${network}`)
    })

    list.append(btn)
  }

  popBox.append(header)
  popBox.append(separator)
  popBox.append(list)

  popover.set_child(popBox)

  wifiButton.set_popover(popover)

  // Hover
  const motion = new Gtk.EventControllerMotion()

  motion.connect("enter", () => {
    popover.popup()
  })

  motion.connect("leave", () => {
    GLib.timeout_add(
      GLib.PRIORITY_DEFAULT,
      300,
      () => {
        popover.popdown()
        return GLib.SOURCE_REMOVE
      }
    )
  })

  wifiButton.add_controller(motion)

  rightBox.append(wifiButton)

  // =========================

  bar.set_start_widget(left)
  bar.set_center_widget(clock)
  bar.set_end_widget(rightBox)

  win.set_child(bar)

  // Clock
  function updateClock() {
    clock.set_label(
      GLib.DateTime.new_now_local().format(
        "%H:%M:%S"
      )
    )

    return GLib.SOURCE_CONTINUE
  }

  updateClock()

  GLib.timeout_add_seconds(
    GLib.PRIORITY_DEFAULT,
    1,
    updateClock
  )

  win.present()
}