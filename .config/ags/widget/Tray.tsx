// ~/.config/ags/widget/Tray.tsx
import AstalTray from "gi://AstalTray"
import { createBinding } from "ags"

export default function Tray() {
  const tray = AstalTray.get_default()

  return (
    <box class="tray">
      {createBinding(tray, "items").as(items =>
        items.map(item => (
          <menubutton
            class="tray-item"
            tooltipMarkup={createBinding(item, "tooltipMarkup")}
            usePopover={false}
            actionGroup={createBinding(item, "actionGroup").as(ag => ["dbusmenu", ag])}
            menuModel={createBinding(item, "menuModel")}
          >
            <icon gicon={createBinding(item, "gicon")} />
          </menubutton>
        ))
      )}
    </box>
  )
}
