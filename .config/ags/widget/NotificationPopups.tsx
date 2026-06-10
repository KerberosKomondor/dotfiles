// ~/.config/ags/widget/NotificationPopups.tsx
import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import { For } from "ags"
import Notifd from "gi://AstalNotifd"
import { popupStack, dismissPopup, urgencyClass, notifIcon } from "../service/notifications"

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      class="NotificationPopups"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.NONE}
      anchor={TOP | RIGHT}
      visible={true}
      application={app}
    >
      <box orientation={1} spacing={8} class="notif-popups">
        <For each={popupStack} id={(notif: Notifd.Notification) => notif.id}>
          {(notif: Notifd.Notification) => {
            const icon = notifIcon(notif)
            return (
              <box
                class={`notif-popup-row ${urgencyClass(notif)}`}
                spacing={10}
                $={(self: any) => {
                  const click = new Gtk.GestureClick()
                  click.connect("pressed", () => dismissPopup(notif))
                  self.add_controller(click)
                }}
              >
                <image
                  class="notif-icon"
                  file={icon.file}
                  iconName={icon.iconName}
                  pixelSize={32}
                  valign={Gtk.Align.START}
                />
                <box orientation={1} hexpand class="notif-content">
                  <label class="notif-app" label={notif.app_name} halign={Gtk.Align.START} />
                  <label class="notif-title" label={notif.summary} halign={Gtk.Align.START} wrap />
                  <label class="notif-body" label={notif.body} halign={Gtk.Align.START} wrap />
                </box>
              </box>
            )
          }}
        </For>
      </box>
    </window>
  )
}
