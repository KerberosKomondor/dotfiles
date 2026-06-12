// ~/.config/ags/widget/VolumePopup.tsx
import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import { createState, createBinding, For } from "ags"
import Wp from "gi://AstalWp"
import {
  defaultSpeakerVolume,
  defaultSpeakerMute,
  setSpeakerVolume,
  toggleSpeakerMute,
  speakers,
  setDefaultDevice,
} from "../service/audio"
import { volumeVisible, setVolumeVisible } from "../app"

export default function VolumePopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, BOTTOM, RIGHT } = Astal.WindowAnchor
  const [activeTab, setActiveTab] = createState(0)

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

        <box class="volume-tabs" spacing={4} homogeneous>
          <button
            class={activeTab.as((t) => (t === 0 ? "volume-tab active" : "volume-tab"))}
            onClicked={() => setActiveTab(0)}
          >
            <label label="Output" />
          </button>
          <button
            class={activeTab.as((t) => (t === 1 ? "volume-tab active" : "volume-tab"))}
            onClicked={() => setActiveTab(1)}
          >
            <label label="Apps" />
          </button>
          <button
            class={activeTab.as((t) => (t === 2 ? "volume-tab active" : "volume-tab"))}
            onClicked={() => setActiveTab(2)}
          >
            <label label="Input" />
          </button>
        </box>

        <box
          class="volume-tab-content"
          orientation={1}
          spacing={4}
          visible={activeTab.as((t) => t === 0)}
        >
          <For each={speakers}>
            {(spk: Wp.Endpoint) => (
              <button
                class={createBinding(spk, "is-default").as((d) =>
                  d ? "volume-device active" : "volume-device",
                )}
                onClicked={() => setDefaultDevice(spk)}
              >
                <box spacing={8}>
                  <image iconName={spk.icon} />
                  <label
                    label={spk.description ?? spk.name ?? "Unknown device"}
                    hexpand
                    halign={Gtk.Align.START}
                  />
                </box>
              </button>
            )}
          </For>
        </box>
      </box>
    </window>
  )
}
