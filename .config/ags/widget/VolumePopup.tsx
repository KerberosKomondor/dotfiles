// ~/.config/ags/widget/VolumePopup.tsx
import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import {
  defaultSpeakerVolume,
  defaultSpeakerMute,
  setSpeakerVolume,
  toggleSpeakerMute,
} from "../service/audio"
import { volumeVisible, setVolumeVisible } from "../app"

export default function VolumePopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, BOTTOM, RIGHT } = Astal.WindowAnchor

  return (
    <window
      class="VolumePopup"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | LEFT | BOTTOM | RIGHT}
      visible={volumeVisible.as((v) => v)}
      application={app}
      $={(self: any) => {
        const ctrl = new Gtk.EventControllerKey()
        ctrl.connect("key-pressed", (_c: any, keyval: number) => {
          if (keyval === Gdk.KEY_Escape) setVolumeVisible(false)
        })
        self.add_controller(ctrl)
        const click = new Gtk.GestureClick()
        click.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        click.connect(
          "pressed",
          (gesture: any, _n: number, x: number, y: number) => {
            const child = self.get_child()
            if (!child) return
            const a = child.get_allocation()
            if (
              x >= a.x &&
              x <= a.x + a.width &&
              y >= a.y &&
              y <= a.y + a.height
            ) {
              gesture.set_state(Gtk.EventSequenceState.DENIED)
            } else {
              setVolumeVisible(false)
            }
          },
        )
        self.add_controller(click)
      }}
    >
      <box
        class="volume-popup"
        orientation={1}
        halign={Gtk.Align.END}
        valign={Gtk.Align.START}
        spacing={8}
      >
        <box class="volume-master" spacing={8}>
          <button class="volume-icon-btn" onClicked={() => toggleSpeakerMute()}>
            <label label={defaultSpeakerMute.as((m) => (m ? "🔇" : "🔊"))} />
          </button>
          <slider
            class="volume-slider"
            hexpand
            min={0}
            max={1}
            step={0.01}
            value={defaultSpeakerVolume}
            onValueChanged={(self: Gtk.Range) => setSpeakerVolume(self.get_value())}
          />
          <label
            class="volume-pct"
            label={defaultSpeakerVolume.as((v) => `${Math.round(v * 100)}%`)}
          />
        </box>
      </box>
    </window>
  )
}
