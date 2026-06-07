// ~/.config/ags/widget/Volume.tsx
import Wp from "gi://AstalWp"
import { createBinding } from "ags"

export default function Volume() {
  const wp = Wp.get_default()
  const speaker = wp?.audio?.get_default_speaker()

  if (!speaker) return <box class="volume"><label label="🔇" /></box>

  const muteAcc = createBinding(speaker, "mute")
  const volAcc = createBinding(speaker, "volume")

  return (
    <eventbox onScroll={(_self, event) => {
      const delta = event.delta_y > 0 ? -0.05 : 0.05
      speaker.volume = Math.max(0, Math.min(1, speaker.volume + delta))
    }}>
      <box class="volume">
        <label label={muteAcc.as(m => m ? "🔇" : "🔊")} />
        <label
          label={volAcc.as(v => ` ${Math.round(v * 100)}%`)}
          visible={muteAcc.as(m => !m)}
        />
      </box>
    </eventbox>
  )
}
