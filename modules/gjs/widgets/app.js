import Gtk from "gi://Gtk?version=4.0"
import Waybar from "./waybar/index.js"
import Notification from "./notification/index.js"

const app = new Gtk.Application()

app.connect("activate", () => {
  Waybar(app)
  Notification(app)
})

app.run([])