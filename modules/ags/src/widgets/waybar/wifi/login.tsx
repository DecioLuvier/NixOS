import { createState } from "ags"
import { Gtk } from "ags/gtk4"
import { selectedNetwork, connect } from "./common"

const [password, setPassword] = createState("")
const [showPassword, setShowPassword] = createState(false)
const [ssid, setSsid] = createState("")

export function NetworkLogin({ stack }: { stack: Gtk.Stack }) {
  const tryConnect = () => {
    const net = selectedNetwork()
    if (net) connect(
      net.hidden ? ssid() : net.ssid,
      password() || undefined,
      net.hidden,
      net.bssid,
    )
    stack.set_visible_child_name("main")
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={16} marginTop={12} marginBottom={12} marginStart={12} marginEnd={12}>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={4} halign={Gtk.Align.CENTER}>
        <image iconName="network-wireless-symbolic" pixelSize={32} />
        <label label="Conectar à rede" cssClasses={["dim-label"]} />
        <label label={selectedNetwork(n => n?.ssid ?? "—")} cssClasses={["title-3"]} />
      </box>

      <box visible={selectedNetwork(n => !!n?.hidden)} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        <label label="Nome da rede (SSID)" xalign={0} cssClasses={["caption"]} />
        <entry
          hexpand
          placeholderText="Digite o SSID..."
          onNotifyText={self => setSsid(self.text)}
        />
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        <label label="Senha" xalign={0} cssClasses={["caption"]} />
        <box spacing={4}>
          <entry
            hexpand
            visibility={showPassword(v => v)}
            placeholderText="Digite a senha..."
            onNotifyText={self => setPassword(self.text)}
            onActivate={tryConnect}
          />
          <button cssClasses={["icon-button"]} onClicked={() => setShowPassword(v => !v)}>
            <image iconName={showPassword(v => v ? "view-conceal-symbolic" : "view-reveal-symbolic")} />
          </button>
        </box>
      </box>

      <box spacing={8} halign={Gtk.Align.END}>
        <button cssClasses={["flat"]} onClicked={() => stack.set_visible_child_name("main")}>
          <label label="Cancelar" />
        </button>
        <button cssClasses={["suggested-action"]} onClicked={tryConnect}>
          <label label="Conectar" />
        </button>
      </box>

    </box>
  )
}