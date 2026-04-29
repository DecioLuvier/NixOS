import { onCleanup } from "ags"
import { Astal, Gdk } from "ags/gtk4"

import app from "ags/gtk4/app"

import Clock from "./clock"
import Workspaces from "./workspaces"
import Mpris from "./player"
import Wireless from "./wifi"
import AudioOutput from "./audio"
import Battery from "./battery"

export default function Bar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  let win: Astal.Window
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  onCleanup(() => win.destroy())

  return (
    <window
      $={(self) => (win = self)}
      visible
      cssName="bar"
      namespace="my-bar"
      name={`bar-${gdkmonitor.connector}`}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <box $type="start">
          <Clock />
          <Mpris />
        </box>

        <box $type="center">
          <Workspaces />
        </box>

        <box $type="end">
          <Wireless />
          <AudioOutput />
          <Battery />
        </box>
      </centerbox>
    </window>
  )
}