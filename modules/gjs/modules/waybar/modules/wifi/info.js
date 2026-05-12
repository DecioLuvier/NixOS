import Gtk from "gi://Gtk?version=4.0"

import { wifiState } from "./common.js"

function _createRow(label, value) {
    const row = new Gtk.Box({
        spacing: 8,
    })

    const left = new Gtk.Label({
        label,
        xalign: 0,
        hexpand: true,
        css_classes: ["dim-label"],
    })

    const right = new Gtk.Label({
        label: value,
        xalign: 1,
    })

    row.append(left)
    row.append(right)

    return {
        row,
        right,
    }
}

function _createEmptyBox() {
    const box = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 8,
        vexpand: true,
        valign: Gtk.Align.CENTER,
        halign: Gtk.Align.CENTER,
    })

    box.append(new Gtk.Label({
        label: "📡",
        css_classes: ["title-1"],
    }))

    box.append(new Gtk.Label({
        label: "Nenhuma rede selecionada",
        css_classes: ["title-3"],
    }))

    box.append(new Gtk.Label({
        label: "Selecione uma rede na lista",
        css_classes: ["dim-label"],
    }))

    return box
}

function _createInfoBox(stack) {
    const box = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 12,
        margin_top: 8,
        margin_bottom: 8,
        margin_start: 8,
        margin_end: 8,
    })

    const header = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 2,
    })

    const title = new Gtk.Label({
        xalign: 0,
        css_classes: ["title-2"],
    })

    const subtitle = new Gtk.Label({
        xalign: 0,
        css_classes: ["dim-label"],
    })

    header.append(title)
    header.append(subtitle)

    const card = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 6,
        css_classes: ["card"],
    })

    const rows = {
        bssid: _createRow("BSSID", ""),
        signal: _createRow("Sinal", ""),
        channel: _createRow("Canal", ""),
        mode: _createRow("Modo", ""),
        rate: _createRow("Velocidade", ""),
        security: _createRow("Segurança", ""),
    }

    Object.values(rows).forEach(({ row }) => {
        card.append(row)
    })

    const footer = new Gtk.Box({
        halign: Gtk.Align.END,
        margin_top: 8,
    })

    const back = new Gtk.Button({
        label: "← Voltar",
    })

    back.connect("clicked", () => {
        stack.set_visible_child_name("main")
    })

    footer.append(back)

    box.append(header)
    box.append(card)
    box.append(footer)

    function update() {
        const network = wifiState.selectedNetwork

        if (!network)
            return

        title.set_label(network.ssid ?? "")

        subtitle.set_label(
            network.active
                ? "Conectado"
                : "Disponível"
        )

        rows.bssid.right.set_label(network.bssid ?? "")
        rows.signal.right.set_label(`${network.strength ?? 0}%`)
        rows.channel.right.set_label(network.channel ?? "")
        rows.mode.right.set_label(network.mode ?? "")
        rows.rate.right.set_label(network.rate ?? "")

        rows.security.right.set_label(
            network.locked
                ? "Protegida"
                : "Aberta"
        )
    }

    update()

    return box
}

export default function NetworkInfo(stack) {
    const container = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.CROSSFADE,
    })

    const empty = _createEmptyBox()
    const info = _createInfoBox(stack)

    container.add_named(empty, "empty")
    container.add_named(info, "info")

    container.set_visible_child_name(
        selectedNetwork()
            ? "info"
            : "empty"
    )

    return container
}