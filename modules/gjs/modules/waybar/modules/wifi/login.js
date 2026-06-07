import Gtk from "gi://Gtk?version=4.0"
import { selectedNetwork, connect, ConnectionStatus } from "./common.js"
import { createState } from "../../../common.js"

const password = createState("")

export default function NetworkLogin() {
  const stack = new Gtk.Stack({ transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT })

  const back = new Gtk.Button({ label: "Voltar", css_classes: ["flat"] })
  back.connect("clicked", () => stack.set_visible_child_name("form"))

  const entry = new Gtk.Entry({ hexpand: true, placeholder_text: "Senha" })
  entry.connect("notify::text", () => password.set(entry.text))

  const tryConnect = async () => {
    const net = selectedNetwork.get()
    if (!net) return
    const result = await connect(net.ssid, password.get() || undefined, net.hidden, net.bssid)
    if (result === ConnectionStatus.CONNECTED) return stack.set_visible_child_name("success")
    if (result === ConnectionStatus.NO_INTERNET) errorLabel.set_label("Sem internet")
    else if (result === ConnectionStatus.WRONG_PASSWORD) errorLabel.set_label("Senha incorreta")
    else if (result === ConnectionStatus.DISCONNECTED) errorLabel.set_label("Desconectado")
    else errorLabel.set_label("Erro")
    stack.set_visible_child_name("error")
  }

  entry.connect("activate", tryConnect)

  const connectBtn = new Gtk.Button({ label: "Conectar", css_classes: ["suggested-action"] })
  connectBtn.connect("clicked", tryConnect)

  const form = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 16, margin_top: 12, margin_bottom: 12, margin_start: 12, margin_end: 12 })
  form.append(new Gtk.Label({ label: "Conectar à rede", css_classes: ["title-3"] }))
  form.append(entry)
  form.append(connectBtn)

  const success = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 12, halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
  success.append(new Gtk.Label({ label: "Conectado", css_classes: ["title-2"] }))
  success.append(back)

  const errorLabel = new Gtk.Label({ css_classes: ["title-3"] })
  const errorBox = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 12, halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER })
  errorBox.append(errorLabel)
  errorBox.append(back)

  stack.add_named(form, "form")
  stack.add_named(success, "success")
  stack.add_named(errorBox, "error")
  stack.set_visible_child_name("form")

  return stack
}