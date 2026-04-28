import Gtk from "gi://Gtk?version=4.0"
import { execAsync } from "ags/process"
import { createState, For, createRoot, createEffect } from "ags"

type Network = {
  ssid: string
  bssid: string
  strength: number
  locked: boolean
  active: boolean
  mode: string
  channel: string
  rate: string
  bars: string
}

const [networks, setNetworks] = createState<Network[]>([])
const [selectedNetwork, setSelectedNetwork] = createState<Network | null>(null)

async function scan() {
  try {
    const out = await execAsync("nmcli -t -f IN-USE,BSSID,SSID,MODE,CHAN,RATE,SIGNAL,BARS,SECURITY --escape yes dev wifi")
    const result: Network[] = []
    for (const line of out.split("\n").filter(Boolean)) {
      const [inUse, bssidEscaped, ssidEscaped, mode, chan, rate, signalStr, bars, security] = line.split(/(?<!\\):/)

      const net: Network = {
        ssid: ssidEscaped.replace(/\\:/g, ":").trim() || "Rede Oculta",
        bssid: bssidEscaped.replace(/\\:/g, ":").trim(),
        strength: Number(signalStr) || 0,
        locked: security !== "--" && security !== "",
        active: inUse === "*",
        mode, 
        channel: chan, 
        rate, 
        bars
      }

      if (!result.some(n => n.ssid === net.ssid))
        result.push(net)
    }
    setNetworks(result.sort((a, b) => b.strength - a.strength))
  } catch (e) {
    console.error(e)
    setNetworks([])
  }
}

// ---------------- UI COMPONENTS ----------------

function Header() {
  return (
    <box cssClasses={["wifi-subheader"]}>
      <label label="Wi-Fi Networks" hexpand xalign={0} />
    </box>
  )
}

function NetworkList({ stack }: { stack: Gtk.Stack }) {
  return (
    <scrolledwindow heightRequest={300} vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}>
      <box orientation={Gtk.Orientation.VERTICAL}>
        <For each={networks}>
          {(net) => (
            <box spacing={4}>
              <button
                hexpand
                onClicked={() => print(`Conectando a ${net.ssid}`)}
                cssClasses={["wifi-connect-btn", net.active ? "active" : ""]}
              >
                <box spacing={8}>
                  <label label={net.ssid} hexpand xalign={0} />
                  {net.active && <label label="✔" />}
                  {net.locked && !net.active && <label label="🔒" />}
                </box>
              </button>
              <button onClicked={() => { setSelectedNetwork(net); stack.set_visible_child_name("details") }}>
                <image iconName="go-next-symbolic" />
              </button>
            </box>
          )}
        </For>
      </box>
    </scrolledwindow>
  )
}

function NetworkInfo({ stack }: { stack: Gtk.Stack }) {
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

// ---------------- MAIN ----------------

export default function Wireless() {
  const stack = new Gtk.Stack({
    transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
    transition_duration: 300,
  })

  stack.add_named(
    <box orientation={Gtk.Orientation.VERTICAL}>
      <Header />
      <NetworkList stack={stack} />
    </box> as any,
    "main"
  )

  stack.add_named(<NetworkInfo stack={stack} /> as any, "details")
  stack.set_visible_child_name("main")

  scan()
  setInterval(scan, 5000)

  return (
    <menubutton cssClasses={["wifi-menu-button"]}>
      <image iconName="network-wireless-signal-excellent-symbolic" />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} widthRequest={350}>
          {stack}
        </box>
      </popover>
    </menubutton>
  )
}