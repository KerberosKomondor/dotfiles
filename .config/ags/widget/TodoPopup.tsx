// ~/.config/ags/widget/TodoPopup.tsx
import { Astal, Gdk } from "ags/gtk3"
import app from "ags/gtk3/app"
import { todoVisible } from "../app"

export default function TodoPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor
  return (
    <window
      class="TodoPopup"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP | LEFT}
      visible={todoVisible as unknown as boolean}
      application={app}
    >
      <box class="todo-popup">
        <label label="todo stub" />
      </box>
    </window>
  )
}
