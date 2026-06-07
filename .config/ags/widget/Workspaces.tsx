// ~/.config/ags/widget/Workspaces.tsx
import Hyprland from "gi://AstalHyprland"
import { createBinding } from "ags"

export default function Workspaces() {
  const hypr = Hyprland.get_default()
  const workspaces = createBinding(hypr, "workspaces")
  const focusedWs = createBinding(hypr, "focusedWorkspace")

  return (
    <box class="workspaces">
      {workspaces.as(wsList => {
        const ids = [...new Set([...wsList.map((w: { id: number }) => w.id), focusedWs()?.id ?? 1])].sort((a: number, b: number) => a - b)
        return ids.map((id: number) => (
          <box class={focusedWs.as(fw => fw?.id === id ? "ws-dot active" : wsList.some((w: { id: number }) => w.id === id) ? "ws-dot occupied" : "ws-dot")} />
        ))
      })}
    </box>
  )
}
