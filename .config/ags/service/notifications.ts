// ~/.config/ags/service/notifications.ts
import Notifd from "gi://AstalNotifd"
import { createState } from "ags"

export const notifd = Notifd.get_default()

export const MAX_VISIBLE = 5

export const [popupStack, setPopupStack] = createState<Notifd.Notification[]>([])
export const [history, setHistory] = createState<Notifd.Notification[]>([])

export function urgencyClass(notif: Notifd.Notification): string {
  switch (notif.urgency) {
    case Notifd.Urgency.LOW: return "low"
    case Notifd.Urgency.CRITICAL: return "critical"
    default: return "normal"
  }
}

export function notifIcon(notif: Notifd.Notification): { file?: string; iconName?: string } {
  const image = notif.get_image()
  if (image) return image.startsWith("/") ? { file: image } : { iconName: image }
  const appIcon = notif.get_app_icon()
  if (appIcon) return appIcon.startsWith("/") ? { file: appIcon } : { iconName: appIcon }
  return { iconName: "dialog-information-symbolic" }
}

export function dismissPopup(notif: Notifd.Notification): void {
  notif.dismiss()
}

export function clearHistory(): void {
  setHistory([])
}

export function removeFromHistory(id: number): void {
  setHistory(h => h.filter(n => n.id !== id))
}

export function invokeAction(notif: Notifd.Notification, actionId: string): void {
  notif.invoke(actionId)
}

notifd.connect("notified", (_src, id: number) => {
  const notif = notifd.get_notification(id)
  if (!notif) return

  setHistory(h => [notif, ...h])

  setPopupStack(stack => {
    const next = [...stack, notif]
    return next.length > MAX_VISIBLE ? next.slice(next.length - MAX_VISIBLE) : next
  })
})

notifd.connect("resolved", (_src, id: number) => {
  setPopupStack(stack => stack.filter(n => n.id !== id))
})
