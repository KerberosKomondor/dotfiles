// ~/.config/ags/widget/Notifications.tsx
import Notifd from "gi://AstalNotifd"
import { createBinding } from "ags"

export default function Notifications() {
  const notifd = Notifd.get_default()
  const notifications = createBinding(notifd, "notifications")

  return (
    <box visible={notifications.as(n => n.length > 0)}>
      <label
        class="notifications"
        label={notifications.as(n => `󰂚 ${n.length}`)}
      />
      <box class="bar-divider" />
    </box>
  )
}
