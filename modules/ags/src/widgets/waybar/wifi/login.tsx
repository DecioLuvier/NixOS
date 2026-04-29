import { createState } from "ags"
import { Gtk } from "ags/gtk4"
import { selectedNetwork } from "./common"

export function NetworkLogin({ stack }: { stack: Gtk.Stack }) {
  const [password, setPassword] = createState("")
  const [showPassword, setShowPassword] = createState(false)

  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={12} marginTop={8} marginBottom={8} marginStart={8} marginEnd={8}>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={2} halign={Gtk.Align.CENTER}>
        <label label="Conectar à rede" cssClasses={["dim-label"]} />
        <label
          label={selectedNetwork(n => n?.ssid ?? "—")}
          cssClasses={["title-3"]}
        />
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        <label label="Senha" xalign={0} cssClasses={["caption"]} />
        <box spacing={4}>
          <entry
            hexpand
            visibility={showPassword()}
            placeholderText="Digite a senha..."
            onNotifyText={self => setPassword(self.text)}
            onActivate={() => {
              print(`Conectando a ${selectedNetwork()?.ssid}`)
              stack.set_visible_child_name("main")
            }}
          />
          <button onClicked={() => setShowPassword(v => !v)}>
            <image iconName={showPassword(v => v ? "view-conceal-symbolic" : "view-reveal-symbolic")} />
          </button>
        </box>
      </box>

      <box spacing={8} halign={Gtk.Align.END} marginTop={4}>
        <button onClicked={() => stack.set_visible_child_name("main")}>
          <label label="Cancelar" />
        </button>
        <button
          cssClasses={["suggested-action"]}
          onClicked={() => {
            print(`Conectando a ${selectedNetwork()?.ssid} senha=${password()}`)
            stack.set_visible_child_name("main")
          }}
        >
          <label label="Conectar" />
        </button>
      </box>

    </box>
  )
}