import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"

export default function WifiModule() {
  const button = new Gtk.MenuButton({
    icon_name:
      "network-wireless-signal-excellent-symbolic",
  })

  const popover = new Gtk.Popover()

  const box = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 8,
    margin_top: 12,
    margin_bottom: 12,
    margin_start: 12,
    margin_end: 12,
    width_request: 320,
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

  // Network list
  const list = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 6,
  })

  const networks = [
    "MinhaCasa_5G",
    "Starlink",
    "Cafe_Wifi",
    "NET_2G",
  ]

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

  box.append(header)
  box.append(separator)
  box.append(list)

  popover.set_child(box)

  button.set_popover(popover)

  // Hover open
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

  button.add_controller(motion)

  return button
}