import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"

export default function ClockModule() {
  const label = new Gtk.Label({
    label: "",
  })

  function updateClock() {
    label.set_label(
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

  return label
}