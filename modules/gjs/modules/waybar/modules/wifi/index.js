import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib"

import NetworkList from "./list.js"
import NetworkInfo from "./info.js"
import NetworkLogin from "./login.js"

import { scan } from "./common.js"

export let stack;

export default function WifiModule() {
    stack = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
        transition_duration: 300,
    })
    
    stack.add_named(NetworkList(), "list" )
    stack.add_named(NetworkInfo(), "info")
    stack.add_named(NetworkLogin(), "login")
    stack.set_visible_child_name("list")

    const popover = new Gtk.Popover()
    popover.set_child(stack)

    const button = new Gtk.MenuButton({ icon_name: "network-wireless-signal-excellent-symbolic" })
    button.set_popover(popover)

    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 5, () => {
            scan()
            return GLib.SOURCE_CONTINUE
        }
    )

    return button
}