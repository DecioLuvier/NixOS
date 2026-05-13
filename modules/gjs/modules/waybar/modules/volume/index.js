import Gtk from "gi://Gtk?version=4.0"

export default function VolumeModule() {
  const button = new Gtk.MenuButton({
    icon_name: "audio-volume-high-symbolic",
  })

  const popover = new Gtk.Popover()

  const box = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 8,
    margin_top: 12,
    margin_bottom: 12,
    margin_start: 12,
    margin_end: 12,
    width_request: 220,
  })

  const label = new Gtk.Label({
    label: "Volume",
    xalign: 0,
  })

  const slider = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    hexpand: true,
  })

  slider.set_range(0, 100)
  slider.set_value(70)

  slider.connect("value-changed", () => {
    const value = Math.floor(slider.get_value())
    print(`Volume: ${value}%`)
  })

  box.append(label)
  box.append(slider)

  popover.set_child(box)

  button.set_popover(popover)

  return button
}