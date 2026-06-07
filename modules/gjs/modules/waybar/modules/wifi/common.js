import NM from "gi://NM"
import GLib from "gi://GLib"
import { createState } from "../../../common.js"

export const networks = createState([])
export const selectedNetwork = createState(null)

export const ConnectionStatus = Object.freeze({
  CONNECTED:      200,
  FAILED:         503,
  NO_INTERNET:    504,
  LOGIN_REQUIRED: 401,
  WRONG_PASSWORD: 403,
})

const client = await new Promise((resolve, reject) => {
  NM.Client.new_async(null, (_, res) => {
    try { resolve(NM.Client.new_finish(res)) }
    catch (e) { reject(e) }
  })
})

export function getWifiStrengthIcon(network) {
  if (network.strength >= 80) return "network-wireless-signal-excellent-symbolic"
  if (network.strength >= 60) return "network-wireless-signal-good-symbolic"
  if (network.strength >= 40) return "network-wireless-signal-ok-symbolic"
  if (network.strength >= 20) return "network-wireless-signal-weak-symbolic"
  return "network-wireless-signal-none-symbolic"
}

export function getWifiStatusIcon(network) {
  if (network.active) return "object-select-symbolic"
  if (network.locked) return "network-wireless-encrypted-symbolic"
  return ""
}

function compareNetwork(a, b) {
  if (a.active !== b.active) return b.active - a.active
  return b.strength - a.strength
}

export function scan() {
  const device = client.get_devices().find(d => d.get_device_type() === NM.DeviceType.WIFI)
  if (!device) return networks.set([])

  const activeAp = device.get_active_access_point()
  const seen = new Map()

  for (const ap of device.get_access_points()) {
    const ssid     = NM.utils_ssid_to_utf8(ap.get_ssid()?.get_data() ?? []) ?? ""
    const strength = ap.get_strength()
    const active   = ap === activeAp
    const locked   = ap.get_rsn_flags() > 0 || ap.get_wpa_flags() > 0

    if (!ssid) continue

    const existing = seen.get(ssid)
    if (!existing || active || strength > existing.strength)
      seen.set(ssid, {
        ssid,
        bssid:   ap.get_bssid(),
        channel: String(NM.utils_wifi_freq_to_channel(ap.get_frequency())),
        rate:    `${ap.get_max_bitrate() / 1000} Mbps`,
        strength,
        active,
        locked,
      })
  }

  networks.set([...seen.values()].sort(compareNetwork))
}

export async function connect(ssid, password = null, hidden = false, bssid = null) {
  try {
    if (password && password.length < 8)
      return ConnectionStatus.WRONG_PASSWORD

    const device = client.get_devices().find(d => d.get_device_type() === NM.DeviceType.WIFI)
    if (!device) return ConnectionStatus.FAILED

    const existing = client.get_connections().find(c => c.get_id() === ssid)
    if (existing) await new Promise((resolve, reject) => {
      client.delete_connection_async(existing, null, (_, res) => {
        try { resolve(client.delete_connection_finish(res)) }
        catch (e) { reject(e) }
      })
    })

    const conn = new NM.SimpleConnection()

    const wireless = NM.SettingWireless.new()
    wireless.set_property("ssid", GLib.Bytes.new(new TextEncoder().encode(ssid)))
    if (hidden) wireless.set_property("hidden", true)
    if (bssid)  wireless.set_property("bssid", bssid)
        
    conn.add_setting(wireless)

    if (password) {
      const security = NM.SettingWirelessSecurity.new()
      security.set_property("key-mgmt", "wpa-psk")
      security.set_property("psk", password)
      conn.add_setting(security)
    }

    await new Promise((resolve, reject) => {
      client.add_and_activate_connection_async(conn, device, null, null, (_, res) => {
        try { resolve(client.add_and_activate_connection_finish(res)) }
        catch (e) { reject(e) }
      })
    })

    return ConnectionStatus.CONNECTED
  } catch (e) {
    console.log(e)
    const msg = String(e).toLowerCase()
    if (msg.includes("secrets") || msg.includes("password"))
      return ConnectionStatus.WRONG_PASSWORD
    return ConnectionStatus.FAILED
  }
}