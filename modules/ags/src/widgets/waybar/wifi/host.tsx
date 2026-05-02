import { createState } from "ags"
import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"

const [ssid, setSsid] = createState("")
const [password, setPassword] = createState("")
const [active, setActive] = createState(false)
const [showPassword, setShowPassword] = createState(false)

async function toggleHotspot() {
  if (active()) {
    await execAsync("nmcli connection down Hotspot")
    setActive(false)
  } else {
    await execAsync(`nmcli device wifi hotspot ssid "${ssid()}" password "${password()}"`)
    setActive(true)
  }
}

export function NetworkHost({ stack }: { stack: Gtk.Stack }) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={12} marginTop={8} marginBottom={8} marginStart={8} marginEnd={8}>
      <box orientation={Gtk.Orientation.VERTICAL} spacing={2} halign={Gtk.Align.CENTER}>
        <label label="Hotspot" cssClasses={["title-3"]} />
        <label label="Compartilhar sua conexão" cssClasses={["dim-label"]} />
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        <label label="Nome da rede (SSID)" xalign={0} cssClasses={["caption"]} />
        <entry
          hexpand
          placeholderText="Nome do hotspot..."
          onNotifyText={self => setSsid(self.text)}
        />
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        <label label="Senha" xalign={0} cssClasses={["caption"]} />
        <box spacing={4}>
          <entry
            hexpand
            visibility={showPassword(v => v)}
            placeholderText="Senha do hotspot..."
            onNotifyText={self => setPassword(self.text)}
          />
          <button onClicked={() => setShowPassword(v => !v)}>
            <image iconName={showPassword(v => v ? "view-conceal-symbolic" : "view-reveal-symbolic")} />
          </button>
        </box>
      </box>

      <box spacing={8} halign={Gtk.Align.END} marginTop={4}>
        <button onClicked={() => stack.set_visible_child_name("main")}>
          <label label="Voltar" />
        </button>
        <button cssClasses={["suggested-action"]} onClicked={toggleHotspot}>
          <label label={active(v => v ? "Desligar" : "Ligar")} />
        </button>
      </box>
    </box>
  )
}