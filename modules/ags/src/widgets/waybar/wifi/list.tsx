import { For } from "ags"
import { Gtk } from "ags/gtk4"
import Pango from "gi://Pango"
import { networks, setSelectedNetwork, getWifiStrengthIcon, getWifiStatusIcon } from "./common"

export function NetworkList({ stack }: { stack: Gtk.Stack }) {
  return (
    <scrolledwindow
      heightRequest={300}
      widthRequest={325}
      vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
    >
      <box orientation={Gtk.Orientation.VERTICAL} css={`padding-right: 12px;`}>
        <For each={networks}>
          {(net) => (
            <box spacing={4} hexpand>
              <button
                hexpand
                cssClasses={net.active ? ["wifi-item", "active"] : ["wifi-item"]}
                onClicked={() => {
                  setSelectedNetwork(net)
                  stack.set_visible_child_name("details")
                }}
              >
                <box spacing={10} hexpand>
                  <image iconName={getWifiStrengthIcon(net)} />
                  <label
                    label={net.ssid}
                    hexpand
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    maxWidthChars={22}
                  />
                  <image iconName={getWifiStatusIcon(net)} />
                </box>
              </button>
              <button
                cssClasses={["wifi-item"]}
                onClicked={() => {
                  setSelectedNetwork(net)
                  stack.set_visible_child_name("login")
                }}
              >
                <image iconName="go-next-symbolic" />
              </button>
            </box>
          )}
        </For>
      </box>
    </scrolledwindow>
  )
}