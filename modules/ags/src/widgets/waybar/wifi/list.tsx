import { For } from "ags"
import { Gtk } from "ags/gtk4"
import { networks, setSelectedNetwork } from "./common"

export function NetworkList({ stack }: { stack: Gtk.Stack }) {
  return (
    <scrolledwindow heightRequest={300} vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}>
      <box orientation={Gtk.Orientation.VERTICAL}>
        <For each={networks}>
          {(net) => (
            <box spacing={4}>
              <button
                hexpand
                onClicked={() => { setSelectedNetwork(net); stack.set_visible_child_name("login") }}
                cssClasses={["wifi-connect-btn", net.active ? "active" : ""]}
              >
                <box spacing={8}>
                  <label label={net.ssid} hexpand xalign={0} />
                  {net.active && <label label="✔" />}
                  {net.locked && !net.active && <label label="🔒" />}
                </box>
              </button>
              <button onClicked={() => { setSelectedNetwork(net); stack.set_visible_child_name("details") }}>
                <image iconName="go-next-symbolic" />
              </button>
            </box>
          )}
        </For>
      </box>
    </scrolledwindow>
  )
}