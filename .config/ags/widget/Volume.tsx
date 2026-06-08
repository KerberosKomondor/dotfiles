// ~/.config/ags/widget/Volume.tsx
import { Gtk } from "ags/gtk4"
import Wp from "gi://AstalWp"
import { createBinding } from "ags"

export default function Volume() {
  const wp = Wp.get_default()
  const speaker = wp?.audio?.get_default_speaker()

  if (!speaker) return <box class="volume"><label label="🔇" /></box>

  const muteAcc = createBinding(speaker, "mute")
  const volAcc = createBinding(speaker, "volume")

  return (
    <box
      class="volume"
      $={(self: Gtk.Box) => {
        const ctrl = new Gtk.EventControllerScroll()
        ctrl.set_flags(Gtk.EventControllerScrollFlags.VERTICAL)
        ctrl.connect("scroll", (_c: any, _dx: number, dy: number) => {
          const delta = dy > 0 ? -0.05 : 0.05
          speaker.volume = Math.max(0, Math.min(1, speaker.volume + delta))
        })
        self.add_controller(ctrl)
      }}
    >
      <label label={muteAcc.as(m => m ? "🔇" : "🔊")} />
      <label
        label={volAcc.as(v => ` ${Math.round(v * 100)}%`)}
        visible={muteAcc.as(m => !m)}
      />
    </box>
  )
}
