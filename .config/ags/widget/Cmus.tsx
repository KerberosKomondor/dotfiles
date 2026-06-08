// ~/.config/ags/widget/Cmus.tsx
import Mpris from "gi://AstalMpris"
import { createBinding, With } from "ags"

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60)
  const s = Math.floor(seconds % 60)
  return `${m}:${s.toString().padStart(2, "0")}`
}

const BROWSER_IDS = ["firefox", "chromium", "chrome", "brave", "vivaldi", "opera", "epiphany"]

function isMusicPlayer(player: Mpris.Player): boolean {
  const bus = (player.busName ?? "").toLowerCase()
  const entry = (player.entry ?? "").toLowerCase()
  return !BROWSER_IDS.some(b => bus.includes(b) || entry.includes(b))
}

export default function Cmus() {
  const mpris = Mpris.get_default()
  const players = createBinding(mpris, "players")
  const musicPlayers = players.as(p => p.filter(isMusicPlayer))

  return (
    <box class="cmus" visible={musicPlayers.as(p => p.length > 0)}>
      <With value={musicPlayers}>
        {(playerList) => {
          const player = playerList[0]
          if (!player) return null
          return (
            <label label={createBinding(player, "title").as(() => {
              const artist = player.artist ?? ""
              const title = player.title ?? ""
              const pos = formatTime(player.position ?? 0)
              const len = formatTime(player.length ?? 0)
              const text = artist ? `${artist} - ${title}` : title
              return `󰝚 ${text} [${pos}/${len}]`
            })} />
          )
        }}
      </With>
    </box>
  )
}
