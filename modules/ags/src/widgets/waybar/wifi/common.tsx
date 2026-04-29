import { createState } from "ags"
import { execAsync } from "ags/process"

export type Network = {
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

export const [networks, setNetworks] = createState<Network[]>([])
export const [selectedNetwork, setSelectedNetwork] = createState<Network | null>(null)

export async function scan() {
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