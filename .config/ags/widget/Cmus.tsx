// ~/.config/ags/widget/Cmus.tsx
import Mpris from "gi://AstalMpris"
import { createBinding } from "ags"

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60)
  const s = Math.floor(seconds % 60)
  return `${m}:${s.toString().padStart(2, "0")}`
}

export default function Cmus() {
  const mpris = Mpris.get_default()

  return (
    <box
      class="cmus"
      visible={createBinding(mpris, "players").as(players => players.length > 0)}
    >
      {createBinding(mpris, "players").as(players => {
        const player = players[0]
        if (!player) return []
        // bind to title so the label re-renders on song change
        return [
          <label label={createBinding(player, "title").as(() => {
            const artist = player.artist ?? ""
            const title = player.title ?? ""
            const pos = formatTime(player.position ?? 0)
            const len = formatTime(player.length ?? 0)
            const text = artist ? `${artist} - ${title}` : title
            return `󰝚 ${text} [${pos}/${len}]`
          })} />
        ]
      })}
    </box>
  )
}
