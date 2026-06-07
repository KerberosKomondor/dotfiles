// ~/.config/ags/widget/Bar.tsx
import { Astal, Gtk, Gdk } from "ags/gtk3"
import app from "ags/gtk3/app"

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
        {/* Left section */}
        <box $type="start" hexpand halign={Gtk.Align.START} class="bar-left">
          <label label="LEFT" />
        </box>
        {/* Right section */}
        <box $type="end" halign={Gtk.Align.END} class="bar-right">
          <label label="RIGHT" />
        </box>
      </box>
    </window>
  )
}
