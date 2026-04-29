import { Gtk } from "ags/gtk4"
import { scan } from "./common"
import { NetworkList } from "./list"
import { NetworkInfo } from "./info"
import { NetworkLogin } from "./login"

function Header() {
  return (
    <box cssClasses={["wifi-subheader"]}>
      <label label="Wi-Fi Networks" hexpand xalign={0} />
    </box>
  )
}

export default function Wireless() {
  const stack = new Gtk.Stack({
    transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
    transition_duration: 300,
  })

  stack.add_named(
    <box orientation={Gtk.Orientation.VERTICAL}>
      <Header />
      <NetworkList stack={stack} />
    </box> as any,
    "main"
  )

  stack.add_named(<NetworkInfo stack={stack} /> as any, "details")
  stack.add_named(<NetworkLogin stack={stack} /> as any, "login")
  stack.set_visible_child_name("main")

  scan()
  setInterval(scan, 5000)

  return (
    <menubutton cssClasses={["wifi-menu-button"]}>
      <image iconName="network-wireless-signal-excellent-symbolic" />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} widthRequest={350}>
          {stack}
        </box>
      </popover>
    </menubutton>
  )
}