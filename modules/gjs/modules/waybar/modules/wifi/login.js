import Gtk from "gi://Gtk?version=4.0"

import {
    selectedNetwork,
    connect,
    ConnectionStatus,
} from "./common.js"

import {
    createState,
} from "../../../common.js"

const password = createState("")
const showPassword = createState(false)
const ssid = createState("")

export default function NetworkLogin() {
    const stack = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
    })

    const form = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 16,
        margin_top: 12,
        margin_bottom: 12,
        margin_start: 12,
        margin_end: 12,
    })

    const errorBox = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 12,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    })

    const errorLabel = new Gtk.Label({
        css_classes: ["title-3"],
    })

    errorBox.append(errorLabel)

    const success = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 12,
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
    })

    success.append(new Gtk.Label({
        label: "Conectado",
        css_classes: ["title-2"],
    }))

    const setError = (text) => {
        errorLabel.set_label(text)
        stack.set_visible_child_name("error")
    }

    const tryConnect = async () => {
        const network = selectedNetwork.get()
        if (!network)
            return

        const result = await connect(
            network.hidden ? ssid.get() : network.ssid,
            password.get() || undefined,
            network.hidden,
            network.bssid
        )

        if (result === ConnectionStatus.CONNECTED) {
            stack.set_visible_child_name("success")
            return
        }

        if (result === ConnectionStatus.NO_INTERNET) {
            setError("Sem internet")
            return
        }

        if (result === ConnectionStatus.WRONG_PASSWORD) {
            setError("Senha incorreta")
            return
        }

        if (result === ConnectionStatus.DISCONNECTED) {
            setError("Desconectado")
            return
        }

        setError("Erro")
    }

    const entry = new Gtk.Entry({
        hexpand: true,
        placeholder_text: "Senha",
    })

    entry.connect("notify::text", () => {
        password.set(entry.text)
    })

    entry.connect("activate", tryConnect)

    const btn = new Gtk.Button({
        label: "Conectar",
        css_classes: ["suggested-action"],
    })

    btn.connect("clicked", tryConnect)

    form.append(new Gtk.Label({
        label: "Conectar à rede",
        css_classes: ["title-3"],
    }))

    form.append(entry)
    form.append(btn)

    const backError = new Gtk.Button({ label: "Voltar", css_classes: ["flat"] })
    backError.connect("clicked", () => stack.set_visible_child_name("form"))
    errorBox.append(backError)

    const backSuccess = new Gtk.Button({ label: "Voltar", css_classes: ["flat"] })
    backSuccess.connect("clicked", () => stack.set_visible_child_name("form"))
    success.append(backSuccess)

    stack.add_named(form, "form")
    stack.add_named(success, "success")
    stack.add_named(errorBox, "error")

    stack.set_visible_child_name("form")

    return stack
}