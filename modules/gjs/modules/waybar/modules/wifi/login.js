import Gtk from "gi://Gtk?version=4.0"

import {
    selectedNetwork,
    connect,
} from "./common.js"

import {
    createState,
    createEffect,
} from "../../../common.js"

const password =
    createState("")

const showPassword =
    createState(false)

const ssid =
    createState("")

function _createHeader() {
    const box = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
        halign: Gtk.Align.CENTER,
    })

    const icon = new Gtk.Image({
        icon_name: "network-wireless-symbolic",
        pixel_size: 32,
    })

    const subtitle = new Gtk.Label({
        label: "Conectar à rede",
        css_classes: ["dim-label"],
    })

    const title = new Gtk.Label({
        css_classes: ["title-3"],
    })

    createEffect(
        selectedNetwork,
        network => {
            title.set_label(
                network?.ssid ?? "—"
            )
        }
    )

    box.append(icon)
    box.append(subtitle)
    box.append(title)

    return box
}

function _createSSIDEntry() {
    const container = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
    })

    const label = new Gtk.Label({
        label: "Nome da rede (SSID)",
        xalign: 0,
        css_classes: ["caption"],
    })

    const entry = new Gtk.Entry({
        hexpand: true,
        placeholder_text: "Digite o SSID...",
    })

    entry.connect("notify::text", () => {
        ssid.set(entry.text)
    })

    createEffect(
        selectedNetwork,
        network => {
            container.set_visible(
                !!network?.hidden
            )
        }
    )

    container.append(label)
    container.append(entry)

    return container
}

function _createPasswordEntry(onConnect) {
    const container = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
    })

    const label = new Gtk.Label({
        label: "Senha",
        xalign: 0,
        css_classes: ["caption"],
    })

    const row = new Gtk.Box({
        spacing: 4,
    })

    const entry = new Gtk.Entry({
        hexpand: true,
        placeholder_text: "Digite a senha...",
    })

    createEffect(
        showPassword,
        visible => {
            entry.set_visibility(visible)
        }
    )

    entry.connect("notify::text", () => {
        password.set(entry.text)
    })

    entry.connect("activate", onConnect)

    const toggle = new Gtk.Button({
        css_classes: ["icon-button"],
    })

    const icon = new Gtk.Image()

    createEffect(
        showPassword,
        visible => {
            icon.set_icon_name(
                visible
                    ? "view-conceal-symbolic"
                    : "view-reveal-symbolic"
            )
        }
    )

    toggle.connect("clicked", () => {
        showPassword.set(
            !showPassword.get()
        )
    })

    toggle.set_child(icon)

    row.append(entry)
    row.append(toggle)

    container.append(label)
    container.append(row)

    return container
}

function _createActions(stack, onConnect) {
    const box = new Gtk.Box({
        spacing: 8,
        halign: Gtk.Align.END,
    })

    const cancel = new Gtk.Button({
        label: "Cancelar",
        css_classes: ["flat"],
    })

    cancel.connect("clicked", () => {
        stack.set_visible_child_name("main")
    })

    const submit = new Gtk.Button({
        label: "Conectar",
        css_classes: ["suggested-action"],
    })

    submit.connect("clicked", onConnect)

    box.append(cancel)
    box.append(submit)

    return box
}

export default function NetworkLogin(stack) {
    async function tryConnect() {
        const network =
            selectedNetwork.get()

        if (!network)
            return

        await connect(
            network.hidden
                ? ssid.get()
                : network.ssid,

            password.get() || undefined,

            network.hidden,

            network.bssid
        )

        stack.set_visible_child_name("main")
    }

    const box = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 16,
        margin_top: 12,
        margin_bottom: 12,
        margin_start: 12,
        margin_end: 12,
    })

    box.append(
        _createHeader()
    )

    box.append(
        _createSSIDEntry()
    )

    box.append(
        _createPasswordEntry(
            tryConnect
        )
    )

    box.append(
        _createActions(
            stack,
            tryConnect
        )
    )

    return box
}