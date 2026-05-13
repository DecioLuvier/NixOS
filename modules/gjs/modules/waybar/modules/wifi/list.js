import Gtk from "gi://Gtk?version=4.0"
import Pango from "gi://Pango"

import {
    networks,
    selectedNetwork,
    getWifiStrengthIcon,
    getWifiStatusIcon,
} from "./common.js"

import {
    createEffect,
} from "../../../common.js"

function _createConnectButton(stack, net) {
    const button = new Gtk.Button({
        hexpand: true,

        css_classes: net.active
            ? ["wifi-item", "active"]
            : ["wifi-item"],
    })

    button.connect("clicked", () => {
        selectedNetwork.set(net)

        stack.set_visible_child_name("info")
    })

    const box = new Gtk.Box({
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

    box.append(strengthIcon)
    box.append(label)
    box.append(statusIcon)

    button.set_child(box)

    return button
}

function _createInfoButton(stack, net) {
    const button = new Gtk.Button({
        css_classes: ["wifi-item"],
    })

    button.connect("clicked", () => {
        selectedNetwork.set(net)

        stack.set_visible_child_name("login")
    })

    button.set_child(
        new Gtk.Image({
            icon_name: "go-next-symbolic",
        })
    )

    return button
}

function _createRow(stack, net) {
    const row = new Gtk.Box({
        spacing: 4,
        hexpand: true,
    })

    row.append(
        _createConnectButton(stack, net)
    )

    row.append(
        _createInfoButton(stack, net)
    )

    return row
}

function _buildList(list, stack, wifiNetworks) {
    let child = list.get_first_child()

    while (child) {
        const next = child.get_next_sibling()

        list.remove(child)

        child = next
    }

    for (const net of wifiNetworks) {
        list.append(
            _createRow(stack, net)
        )
    }
}

export default function NetworkList(stack) {
    const scrolled = new Gtk.ScrolledWindow({
        height_request: 300,
        width_request: 325,
        vscrollbar_policy:
            Gtk.PolicyType.AUTOMATIC,
    })

    const list = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 4,
        margin_end: 12,
    })

    createEffect(
        networks,
        wifiNetworks => {
            _buildList(
                list,
                stack,
                wifiNetworks
            )
        }
    )

    scrolled.set_child(list)

    return scrolled
}