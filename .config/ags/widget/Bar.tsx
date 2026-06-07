// ~/.config/ags/widget/Bar.tsx
import { Astal, Gtk, Gdk } from "ags/gtk3"
import app from "ags/gtk3/app"
import DashboardButton from "./DashboardButton"
import Workspaces from "./Workspaces"
import WindowTitle from "./WindowTitle"
import Volume from "./Volume"
import Clock from "./Clock"
import Cmus from "./Cmus"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <box>
        <box $type="start" hexpand halign={Gtk.Align.START} class="bar-left">
          <DashboardButton />
          <Workspaces />
          <WindowTitle />
        </box>
        <box $type="end" halign={Gtk.Align.END} class="bar-right">
          <Cmus />
          <box class="bar-divider" />
          <Volume />
          <label class="bar-sep" label="·" />
          <Clock />
          <box class="bar-divider" />
        </box>
      </box>
    </window>
  )
}
