import { createState } from "ags"
import { execAsync } from "ags/process"

export type Network = {
  ssid: string
  bssid: string
  strength: number
  locked: boolean
  active: boolean
  hidden: boolean
  mode: string
  channel: string
  rate: string
  bars: string
}

export const [networks, setNetworks] = createState<Network[]>([])
export const [selectedNetwork, setSelectedNetwork] = createState<Network | null>(null)

export function getWifiStrengthIcon(network: Network) : string {
  if (network.strength >= 80) return "network-wireless-signal-excellent-symbolic"
  if (network.strength >= 60) return "network-wireless-signal-good-symbolic"
  if (network.strength >= 40) return "network-wireless-signal-ok-symbolic"
  if (network.strength >= 20) return "network-wireless-signal-weak-symbolic"
  return "network-wireless-signal-none-symbolic"
}

export function getWifiStatusIcon(network: Network): string {
  if (network.active) return "object-select-symbolic"
  if (network.locked) return "network-wireless-encrypted-symbolic"
  return ""
}

function parseLine(line: string): Network {
  const [inUse, bssid, ssid, mode, channel, rate, signal, bars, security] = line.split(/(?<!\\):/)
  
  return {
    ssid:     ssid.replace(/\\:/g, ":").trim() || "Hidden",
    bssid:    bssid.replace(/\\:/g, ":").trim(),
    strength: Number(signal) || 0,
    active:   inUse.trim() === "*",
    locked:   security !== "--" && security?.trim() !== "",
    hidden:   ssid.replace(/\\:/g, ":").trim() === "",
    mode, channel, rate, bars,
  }
}

function compareNetwork(a: Network, b: Network): number {
  if (a.active !== b.active) {
    if (b.active) 
        return 1
    return -1
  }
  return b.strength - a.strength
}

export async function scan() {
  try {
    const cmd = "nmcli -t -f IN-USE,BSSID,SSID,MODE,CHAN,RATE,SIGNAL,BARS,SECURITY --escape yes dev wifi"
    const out = await execAsync(cmd)

    const networks: Network[] = []

    for (const line of out.split("\n")) {
      const network = parseLine(line)
      const isOnNetworks = networks.find(n => n.ssid === network.ssid)
      if (!isOnNetworks)
        networks.push(network)
      else if (compareNetwork(isOnNetworks, network) > 0)
        networks.splice(networks.indexOf(isOnNetworks), 1, network)
    }

    networks.sort(compareNetwork)

    setNetworks(networks)
  } catch (e) {
    console.error(e)
    setNetworks([])
  }
}

export type ConnectionStatus =
  | "connected"
  | "disconnected"
  | "no-internet"
  | "login-required"
  | "wrong-password"

export async function connect(ssid: string, password?: string, hidden?: boolean, bssid?: string): Promise<ConnectionStatus> {
  try {
    if (password && password.length < 8) return "wrong-password"

    let cmd = `nmcli -w 5 dev wifi connect "${ssid}"`
    if (password) cmd += ` password "${password}"`
    if (bssid) cmd += ` bssid "${bssid}"`
    if (hidden) cmd += ` hidden yes`

    await execAsync(cmd)

    const response = await execAsync("curl -I -s --max-time 1 --connect-timeout 1 http://neverssl.com")
    if (response.includes(" 30")) {
      await execAsync("xdg-open http://neverssl.com")
      return "login-required"
    }
    if (response.includes(" 200")) 
      return "connected"
    return "no-internet"
  } catch (e) {
    const msg = String(e)
    if (msg.includes("Timeout")) 
      return "wrong-password"
    return "disconnected"
  }
}