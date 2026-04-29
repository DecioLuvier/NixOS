import app from "ags/gtk4/app"

import style from "./style.scss"
import Bar from "./waybar/waybar"

app.start({
  css: style,
  main() {
    app.get_monitors().map((monitor) =>
      Bar({ gdkmonitor: monitor })
    )
  },
})
