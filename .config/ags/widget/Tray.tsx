// ~/.config/ags/widget/Tray.tsx
import { Gtk } from "ags/gtk3"
import AstalTray from "gi://AstalTray"
import { createBinding, For, onCleanup } from "ags"

export default function Tray() {
  const tray = AstalTray.get_default()

  return (
    <box class="tray" spacing={4}>
      <For each={createBinding(tray, "items")}>
        {(item) => (
          <menubutton
            class="tray-item"
            tooltipMarkup={createBinding(item, "tooltipMarkup")}
            usePopover={false}
            menuModel={createBinding(item, "menuModel")}
            $={(self: Gtk.MenuButton) => {
              const update = () => {
                if (item.actionGroup)
                  self.insert_action_group("dbusmenu", item.actionGroup)
              }
              update()
              const dispose = createBinding(item, "actionGroup").subscribe(update)
              onCleanup(dispose)
            }}
          >
            <icon gicon={createBinding(item, "gicon")} />
          </menubutton>
        )}
      </For>
    </box>
  )
}
