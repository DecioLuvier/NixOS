import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"

import NetworkList from "./list.js"
import NetworkInfo from "./info.js"
import NetworkLogin from "./login.js"

import { scan } from "./common.js"

export default function WifiModule() {
    scan()

    const button = new Gtk.MenuButton({
        icon_name: "network-wireless-signal-excellent-symbolic",
    })

    const popover = new Gtk.Popover()

    const stack = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
        transition_duration: 300,
    })

    stack.add_named(
        NetworkList(stack),
        "main"
    )

    stack.add_named(
        NetworkInfo(stack),
        "info"
    )

    stack.add_named(
        NetworkLogin(stack),
        "login"
    )

    stack.set_visible_child_name("main")

    popover.set_child(stack)

    button.set_popover(popover)

    GLib.timeout_add_seconds(
        GLib.PRIORITY_DEFAULT,
        5,
        () => {
            scan()

            return GLib.SOURCE_CONTINUE
        }
    )

    return button
}