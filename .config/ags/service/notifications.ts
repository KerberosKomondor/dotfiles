// ~/.config/ags/service/notifications.ts
import Notifd from "gi://AstalNotifd"
import { createState } from "ags"

export const notifd = Notifd.get_default()

export const MAX_VISIBLE = 5

export interface PopupGroup {
  appName: string
  notif: Notifd.Notification // currently displayed (latest)
  count: number              // total notifs folded into this group
}

export const [popupStack, setPopupStack] = createState<PopupGroup[]>([])
export const [overflowCount, setOverflowCount] = createState(0)
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

// --- Auto-dismiss timers ---
// low: 8s, normal: 10s, critical: never (matches the old mako config)

const URGENCY_TIMEOUT_MS: Record<number, number | null> = {
  [Notifd.Urgency.LOW]: 8000,
  [Notifd.Urgency.NORMAL]: 10000,
  [Notifd.Urgency.CRITICAL]: null,
}

interface TimerState {
  sourceId: number | null
  total: number | null   // null = critical, never expires
  runRemaining: number   // ms remaining at the start of the current run (or when paused)
  startedAt: number      // Date.now() when the current run started
}

const timers = new Map<number, TimerState>()

function scheduleRun(id: number, remainingMs: number, total: number | null): void {
  const sourceId = setTimeout(() => {
    const notif = notifd.get_notification(id)
    if (notif) notif.dismiss()
  }, remainingMs)
  timers.set(id, { sourceId, total, runRemaining: remainingMs, startedAt: Date.now() })
}

function startTimer(id: number, urgency: Notifd.Urgency): void {
  const total = urgency in URGENCY_TIMEOUT_MS ? URGENCY_TIMEOUT_MS[urgency] : 10000
  if (total === null) {
    timers.set(id, { sourceId: null, total: null, runRemaining: 0, startedAt: 0 })
    return
  }
  scheduleRun(id, total, total)
}

function clearTimer(id: number): void {
  const t = timers.get(id)
  if (t?.sourceId !== null && t?.sourceId !== undefined) clearTimeout(t.sourceId)
  timers.delete(id)
}

export function pauseTimer(id: number): void {
  const t = timers.get(id)
  if (!t || t.sourceId === null) return
  clearTimeout(t.sourceId)
  const elapsed = Date.now() - t.startedAt
  const remaining = Math.max(0, t.runRemaining - elapsed)
  timers.set(id, { ...t, sourceId: null, runRemaining: remaining })
}

export function resumeTimer(id: number): void {
  const t = timers.get(id)
  if (!t || t.total === null || t.sourceId !== null) return
  scheduleRun(id, t.runRemaining, t.total)
}

// Fraction of time remaining (0-1), or null if the notification never expires
export function getTimerFraction(id: number): number | null {
  const t = timers.get(id)
  if (!t || t.total === null) return null
  if (t.sourceId === null) return t.runRemaining / t.total
  const elapsed = Date.now() - t.startedAt
  return Math.max(0, t.runRemaining - elapsed) / t.total
}

notifd.connect("notified", (_src, id: number) => {
  const notif = notifd.get_notification(id)
  if (!notif) return

  setHistory(h => [notif, ...h])

  if (notifd.dontDisturb) return

  setPopupStack(stack => {
    const idx = stack.findIndex(g => g.appName === notif.app_name)
    if (idx !== -1) {
      clearTimer(stack[idx].notif.id)
      const next = [...stack]
      next[idx] = { appName: notif.app_name, notif, count: stack[idx].count + 1 }
      return next
    }

    let next = stack
    if (stack.length >= MAX_VISIBLE) {
      const dropped = stack[0]
      clearTimer(dropped.notif.id)
      setOverflowCount(n => n + dropped.count)
      next = stack.slice(1)
    }
    return [...next, { appName: notif.app_name, notif, count: 1 }]
  })

  startTimer(id, notif.urgency)
})

notifd.connect("resolved", (_src, id: number) => {
  clearTimer(id)
  setPopupStack(stack => {
    const next = stack.filter(g => g.notif.id !== id)
    if (next.length === 0) setOverflowCount(0)
    return next
  })
})
