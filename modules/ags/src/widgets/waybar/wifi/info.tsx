import { createRoot, createEffect } from "ags"
import { Gtk } from "ags/gtk4"
import { selectedNetwork } from "./common"

export function NetworkInfo({ stack }: { stack: Gtk.Stack }) {
  const emptyBox = (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={4} vexpand valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
      <label label="📡 Nenhuma rede selecionada" />
      <label label="Selecione uma rede na lista" />
    </box>
  ) as Gtk.Widget

  const infoBox = (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
      <label label={selectedNetwork(n => n?.ssid ?? "")} />
      <label label={selectedNetwork(n => `BSSID: ${n?.bssid ?? ""}`)} />
      <label label={selectedNetwork(n => `Sinal: ${n?.strength ?? 0}%`)} />
      <label label={selectedNetwork(n => `Canal: ${n?.channel ?? ""}`)} />
      <label label={selectedNetwork(n => `Modo: ${n?.mode ?? ""}`)} />
      <label label={selectedNetwork(n => `Velocidade: ${n?.rate ?? ""}`)} />
      <label label={selectedNetwork(n => `Segurança: ${n?.locked ? "Sim" : "Não"}`)} />
      <label label={selectedNetwork(n => `Ativa: ${n?.active ? "Sim" : "Não"}`)} />
    </box>
  ) as Gtk.Widget

  const innerStack = new Gtk.Stack()
  innerStack.add_named(emptyBox, "empty")
  innerStack.add_named(infoBox, "info")
  innerStack.set_visible_child_name("empty")

  createRoot(() => {
    createEffect(() => {
      innerStack.set_visible_child_name(selectedNetwork() ? "info" : "empty")
    })
  })

  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={12}>
      {innerStack}
      <button onClicked={() => stack.set_visible_child_name("main")}>
        <label label="← Voltar" />
      </button>
    </box>
  )
}