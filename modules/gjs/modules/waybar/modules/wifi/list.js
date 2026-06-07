import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"

import { networks, selectedNetwork, getWifiStrengthIcon, getWifiStatusIcon } from "./common.js"
import { createEffect } from "../../../common.js"
import { stack } from "./index.js"

function createConnectBtn(net) {
    const btn = new Gtk.Button({ hexpand: true })
    btn.connect("clicked", () => {
        selectedNetwork.set(net)
        stack.set_visible_child_name("info")
    })

    const box = new Gtk.Box({ spacing: 10, hexpand: true })
    box.append(new Gtk.Image({ icon_name: getWifiStrengthIcon(net) }))
    box.append(new Gtk.Label({
        label: net.ssid,
        hexpand: true,
        xalign: 0,
        max_width_chars: 22,
        ellipsize: Pango.EllipsizeMode.END,
    }))
    box.append(new Gtk.Image({ icon_name: getWifiStatusIcon(net) }))
    btn.set_child(box)
    return btn
}

function createInfoBtn(net) {
    const btn = new Gtk.Button()
    btn.connect("clicked", () => {
        selectedNetwork.set(net)
        stack.set_visible_child_name("login")
    })
    btn.set_child(new Gtk.Image({ icon_name: "go-next-symbolic" }))
    return btn
}

export default function NetworkList() {
    const list = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
        margin_end: 12,
    })

    createEffect(networks, () => {
        while (list.get_first_child())
            list.remove(list.get_first_child())
        
        for (const net of networks.get()) {
            const row = new Gtk.Box({ spacing: 4, hexpand: true })
            row.append(createConnectBtn(net))
            row.append(createInfoBtn(net))
            list.append(row)
        }
    })

    const scrolled = new Gtk.ScrolledWindow({
        height_request: 300,
        width_request: 325,
        vscrollbar_policy: Gtk.PolicyType.AUTOMATIC
    })
    scrolled.set_child(list)
    
    return scrolled
}