import { createRoot, createEffect } from "ags"
import { Gtk } from "ags/gtk4"
import { selectedNetwork } from "./common"

export function NetworkInfo({ stack }: { stack: Gtk.Stack }) {

  const emptyBox = (
    <box
      orientation={Gtk.Orientation.VERTICAL}
      spacing={8}
      vexpand
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    >
      <label label="📡" cssClasses={["title-1"]} />
      <label label="Nenhuma rede selecionada" cssClasses={["title-3"]} />
      <label label="Selecione uma rede na lista" cssClasses={["dim-label"]} />
    </box>
  ) as Gtk.Widget

  const infoBox = (
    <box
      orientation={Gtk.Orientation.VERTICAL}
      spacing={12}
      marginTop={8}
      marginBottom={8}
      marginStart={8}
      marginEnd={8}
    >
      {/* 🔷 Header */}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={2}>
        <label
          label={selectedNetwork(n => n?.ssid ?? "")}
          cssClasses={["title-2"]}
          xalign={0}
        />
        <label
          label={selectedNetwork(n => n?.active ? "Conectado" : "Disponível")}
          cssClasses={["dim-label"]}
          xalign={0}
        />
      </box>

      {/* 🔷 Infos */}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={6} cssClasses={["card"]}>
        {row("BSSID", selectedNetwork(n => n?.bssid ?? ""))}
        {row("Sinal", selectedNetwork(n => `${n?.strength ?? 0}%`))}
        {row("Canal", selectedNetwork(n => n?.channel ?? ""))}
        {row("Modo", selectedNetwork(n => n?.mode ?? ""))}
        {row("Velocidade", selectedNetwork(n => n?.rate ?? ""))}
        {row("Segurança", selectedNetwork(n => n?.locked ? "Protegida" : "Aberta"))}
      </box>
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
    <box orientation={Gtk.Orientation.VERTICAL} vexpand>
      {/* conteúdo */}
      <box vexpand>
        {innerStack}
      </box>

      {/* footer */}
      <box marginTop={8} marginBottom={8} marginEnd={8} halign={Gtk.Align.END}>
        <button onClicked={() => stack.set_visible_child_name("main")}>
          <label label="← Voltar" />
        </button>
      </box>
    </box>
  )
}

/* 🔧 helper pra linha bonita */
function row(label: string, value: any) {
  return (
    <box spacing={8}>
      <label
        label={label}
        xalign={0}
        hexpand
        cssClasses={["dim-label"]}
      />
      <label
        label={value}
        xalign={1}
      />
    </box>
  )
}