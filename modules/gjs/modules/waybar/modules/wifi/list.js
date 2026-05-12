// waybar/modules/wifi/List.js

import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"

import {
    wifiState,
    getWifiStrengthIcon,
    getWifiStatusIcon,
} from "./WifiService.js"

export default function NetworkList(stack) {
    const scrolled = new Gtk.ScrolledWindow({
        height_request: 300,
        width_request: 325,
        vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
    })

    const list = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
        margin_end: 12,
    })

    for(const net of wifiState.networks) {
        const row = new Gtk.Box({
            spacing: 4,
            hexpand: true,
        })

        const connectButton = new Gtk.Button({
            hexpand: true,
            css_classes: net.active
                ? ["wifi-item", "active"]
                : ["wifi-item"],
        })

        connectButton.connect("clicked", () => {
            wifiState.selectedNetwork = net

            stack.set_visible_child_name("details")
        })

        const connectBox = new Gtk.Box({
            spacing: 10,
            hexpand: true,
        })

        const strengthIcon = new Gtk.Image({
            icon_name: getWifiStrengthIcon(net),
        })

        const label = new Gtk.Label({
            label: net.ssid,
            hexpand: true,
            xalign: 0,
            max_width_chars: 22,
            ellipsize: Pango.EllipsizeMode.END,
        })

        const statusIcon = new Gtk.Image({
            icon_name: getWifiStatusIcon(net),
        })

        connectBox.append(strengthIcon)
        connectBox.append(label)
        connectBox.append(statusIcon)

        connectButton.set_child(connectBox)

        const detailsButton = new Gtk.Button({
            css_classes: ["wifi-item"],
        })

        detailsButton.connect("clicked", () => {
            wifiState.selectedNetwork = net

            stack.set_visible_child_name("login")
        })

        detailsButton.set_child(
            new Gtk.Image({
                icon_name: "go-next-symbolic",
            })
        )

        row.append(connectButton)
        row.append(detailsButton)

        list.append(row)
    }

    scrolled.set_child(list)

    return scrolled
}