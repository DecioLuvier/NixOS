import Gtk from "gi://Gtk?version=4.0"

import NetworkList from "./List.js"

export default function WifiModule() {
    const stack = new Gtk.Stack({
        transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
        transition_duration: 300,
    })

    stack.add_named(
        NetworkList(stack),
        "main"
    )

    stack.set_visible_child_name("main")

    return stack
}