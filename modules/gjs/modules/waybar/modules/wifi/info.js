import Gtk from "gi://Gtk?version=4.0"
import { selectedNetwork } from "./common.js"
import { createEffect } from "../../../common.js"
import { stack } from "./index.js"

function createRow(label) {
  const box = new Gtk.Box({ spacing: 8 })
  const right = new Gtk.Label({ xalign: 1 })
  box.append(new Gtk.Label({ label, xalign: 0, hexpand: true, css_classes: ["dim-label"] }))
  box.append(right)
  return right
}

function createEmptyBox() {
  const box = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 8,
    vexpand: true,
    valign: Gtk.Align.CENTER,
    halign: Gtk.Align.CENTER,
  })
  box.append(new Gtk.Label({ label: "📡", css_classes: ["title-1"] }))
  box.append(new Gtk.Label({ label: "Nenhuma rede selecionada", css_classes: ["title-3"] }))
  box.append(new Gtk.Label({ label: "Selecione uma rede na lista", css_classes: ["dim-label"] }))
  return box
}

function createInfoBox() {
  const title    = new Gtk.Label({ xalign: 0, css_classes: ["title-2"] })
  const subtitle = new Gtk.Label({ xalign: 0, css_classes: ["dim-label"] })

  const bssid    = createRow("BSSID")
  const signal   = createRow("Sinal")
  const channel  = createRow("Canal")
  const mode     = createRow("Modo")
  const rate     = createRow("Velocidade")
  const security = createRow("Segurança")

  const card = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6, css_classes: ["card"] })
  for (const r of [bssid, signal, channel, mode, rate, security])
    card.append(r.get_parent())

  const back = new Gtk.Button({ label: "← Voltar" })
  back.connect("clicked", () => stack.set_visible_child_name("list"))

  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 12, margin_top: 8, margin_bottom: 8, margin_start: 8, margin_end: 8 })
  box.append(title)
  box.append(subtitle)
  box.append(card)
  box.append(back)

  createEffect(selectedNetwork, net => {
    if (!net) return
    title.set_label(net.ssid ?? "")
    subtitle.set_label(net.active ? "Conectado" : "Disponível")
    bssid.set_label(net.bssid ?? "")
    signal.set_label(`${net.strength ?? 0}%`)
    channel.set_label(net.channel ?? "")
    mode.set_label(net.mode ?? "")
    rate.set_label(net.rate ?? "")
    security.set_label(net.locked ? "Protegida" : "Aberta")
  })

  return box
}

export default function NetworkInfo() {
  const container = new Gtk.Stack({ transition_type: Gtk.StackTransitionType.CROSSFADE })
  container.add_named(createEmptyBox(), "empty")
  container.add_named(createInfoBox(), "info")
  createEffect(selectedNetwork, net => container.set_visible_child_name(net ? "info" : "empty"))
  return container
}