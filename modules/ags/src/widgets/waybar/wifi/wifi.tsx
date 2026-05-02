import { Gtk } from "ags/gtk4"
import { scan } from "./common"
import { NetworkList } from "./list"
import { NetworkInfo } from "./info"
import { NetworkLogin } from "./login"
import { NetworkHost } from "./host"

function Header({ stack }: { stack: Gtk.Stack }) {
  return (
    <box
      orientation={Gtk.Orientation.VERTICAL}
      cssClasses={["wifi-header"]}
      spacing={8}
    >
      <box orientation={Gtk.Orientation.HORIZONTAL} hexpand>
        <label label="Wi-Fi" xalign={0} hexpand />
        <switch valign={Gtk.Align.CENTER} active />
      </box>
      <Gtk.Separator orientation={Gtk.Orientation.HORIZONTAL} hexpand />
      <box orientation={Gtk.Orientation.HORIZONTAL} hexpand>
        <label label="Wi-Fi Networks" xalign={0} hexpand />
        <button onClicked={() => stack.set_visible_child_name("host")}>
          <label label="Hotspot" />
        </button>
      </box>
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
      <Header stack={stack} />
      <NetworkList stack={stack} />
    </box> as any,
    "main"
  )
  stack.add_named(<NetworkInfo stack={stack} /> as any, "details")
  stack.add_named(<NetworkLogin stack={stack} /> as any, "login")
  stack.add_named(<NetworkHost stack={stack} /> as any, "host")
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