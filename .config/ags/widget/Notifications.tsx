// ~/.config/ags/widget/Notifications.tsx
import Notifd from "gi://AstalNotifd"
import { createBinding } from "ags"

export default function Notifications() {
  const notifd = Notifd.get_default()

  return (
    <box
      class="notifications"
      visible={createBinding(notifd, "notifications").as(n => n.length > 0)}
    >
      <label
        label={createBinding(notifd, "notifications").as(n => `󰂚 ${n.length}`)}
      />
    </box>
  )
}
