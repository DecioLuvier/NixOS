import app from "ags/gtk4/app"

import Bar from "./widgets/waybar/waybar"

app.start({
  main() {
    app.get_monitors().map((monitor) =>
      Bar({ gdkmonitor: monitor })
    )
  },
})
