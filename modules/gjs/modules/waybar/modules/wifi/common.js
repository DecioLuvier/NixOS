import { exec, execAsync } from "../../../common.js"

export const wifiState = { networks: [], selectedNetwork: null }

export const ConnectionStatus = {
    CONNECTED: "connected",
    DISCONNECTED: "disconnected",
    NO_INTERNET: "no-internet",
    LOGIN_REQUIRED: "login-required",
    WRONG_PASSWORD: "wrong-password"
}

export function getWifiStrengthIcon(network) {
    if(network.strength >= 80)
        return "network-wireless-signal-excellent-symbolic"
    else if(network.strength >= 60)
        return "network-wireless-signal-good-symbolic"
    else if(network.strength >= 40)
        return "network-wireless-signal-ok-symbolic"
    else if(network.strength >= 20)
        return "network-wireless-signal-weak-symbolic"
    else
      return "network-wireless-signal-none-symbolic"
}

export function getWifiStatusIcon(network) {
    if(network.active)
        return "object-select-symbolic"
    else if(network.locked)
        return "network-wireless-encrypted-symbolic"
    else
      return ""
}

function parseLine(line) {
    const [inUse, bssid, ssid, mode, channel, rate, signal, bars, security] = line.split(/(?<!\\):/)
    const parsedSSID = ssid.replace(/\\:/g, ":").trim()

    return {
        ssid: parsedSSID || "Hidden",
        bssid: bssid.replace(/\\:/g, ":").trim(),
        strength: Number(signal) || 0,
        active: inUse.trim() === "*",
        locked: security !== "--" && security?.trim() !== "",
        hidden: parsedSSID === "",
        mode,
        channel,
        rate,
        bars
    }
}

function compareNetwork(a, b) {
    if(a.active !== b.active) {
        if(b.active)
            return 1
        else
            return -1
    } 
    else
        return b.strength - a.strength
}

export function scan() {
    try {
        const out = exec("nmcli -t -f IN-USE,BSSID,SSID,MODE,CHAN,RATE,SIGNAL,BARS,SECURITY --escape yes dev wifi")
        const networks = []

        for(const line of out.trim().split("\n")) {
            if(!line.trim())
                continue

            const network = parseLine(line)

            const existing = networks.find(n => n.ssid === network.ssid)

            if(!existing)
                networks.push(network)
            else if(compareNetwork(existing, network) > 0)
                networks.splice(networks.indexOf(existing), 1, network)
        }

        networks.sort(compareNetwork)

        wifiState.networks = networks
    } catch(e) {
        logError(e)
        wifiState.networks = []
    }
}

export async function connect(ssid, password = null, hidden = false, bssid = null) {
    try {
        if(password && password.length < 8)
            return ConnectionStatus.WRONG_PASSWORD

        let cmd = `nmcli -w 5 dev wifi connect "${ssid}"`
        if(password)
            cmd += ` password "${password}"`
        if(bssid)
            cmd += ` bssid "${bssid}"`
        if(hidden)
            cmd += ` hidden yes`

        await execAsync(cmd)
        const out = await execAsync("curl -I -s --max-time 1 --connect-timeout 1 http://neverssl.com")

        if(out.includes(" 30")) {
            execAsync("xdg-open http://neverssl.com")
            return ConnectionStatus.LOGIN_REQUIRED
        }
        else if(out.includes(" 200"))
            return ConnectionStatus.CONNECTED
        else
          return ConnectionStatus.NO_INTERNET
    } catch(e) {
        const msg = String(e)

        if(msg.includes("Timeout"))
            return ConnectionStatus.WRONG_PASSWORD
        else
          return ConnectionStatus.DISCONNECTED
    }
}