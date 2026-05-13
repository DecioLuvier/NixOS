import { exec, execAsync, createState } from "../../../common.js"

export const networks = createState([])
export const selectedNetwork = createState(null)

export const ConnectionStatus = Object.freeze({
    CONNECTED: 200,
    DISCONNECTED: 503,
    NO_INTERNET: 504,
    LOGIN_REQUIRED: 401,
    WRONG_PASSWORD: 403
});

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
    const [inUse, bssid, ssid, channel, frequency, rate, signal, security] = line.split(/(?<!\\):/)

    return {
        active: inUse?.trim() === "*",
        ssid: (ssid || "").replace(/\\:/g, ":").trim(),
        bssid: (bssid || "").replace(/\\:/g, ":").trim(),
        channel,
        frequency,
        rate,
        signal: Number(signal) || 0,
        security: (security || "").trim()
    }
}

function compareNetwork(a, b) {
    if (a.active !== b.active)
        return b.active - a.active
    return b.strength - a.strength
}

function addOrReplaceNetwork(list, network) {
    if (!network.ssid) return

    const index = list.findIndex(n => n.ssid === network.ssid)

    if (index === -1) {
        list.push(network)
        return
    }

    if (compareNetwork(list[index], network) > 0) 
        list[index] = network
}

export function scan() {
    try {
        const out = exec(["nmcli", "-t", "-f IN-USE,BSSID,SSID,CHAN,FREQ,RATE,SIGNAL,SECURITY", "--escape yes", "dev wifi"])
        const networks = []

        for (const line of out.trim().split("\n")) 
            addOrReplaceNetwork(networks, parseLine(line))
        
        networks.sort(compareNetwork)
        networks.set(networks)
    } catch (e) {
        console.log(e)
        networks.set([])
    }
}

export async function connect(ssid, password = null, hidden = false, bssid = null) {
    try {
        if (password && password.length < 8)
            return ConnectionStatus.WRONG_PASSWORD

        const args = [
            "nmcli", 
            "dev", 
            "wifi", 
            "connect", 
            ssid
        ]

        if (password) args.push("password", password)
        if (bssid) args.push("bssid", bssid)
        if (hidden) args.push("hidden", "yes")

        await execAsync(args)

        let hasInternet = false

        try {

        } catch (e) {
            hasInternet = true
        }

        if (!hasInternet)
            return ConnectionStatus.LOGIN_REQUIRED

        return ConnectionStatus.CONNECTED

    } catch (e) {
        const msg = String(e)
        console.log(msg)
        if (msg.includes("secrets") || msg.includes("password"))
            return ConnectionStatus.WRONG_PASSWORD

        return ConnectionStatus.DISCONNECTED
    }
}

/*
            await execAsync([
                "curl",
                "-I",
                "-s",
                "--max-time",
                "2",
                "--connect-timeout",
                "2",
                "http://neverssl.com"
            ])
*/