// ~/.config/ags/app.ts
import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import WeatherPopup from "./widget/WeatherPopup"
import Dashboard from "./widget/Dashboard"
import TodoPopup from "./widget/TodoPopup"
import CalendarPopup from "./widget/CalendarPopup"
import NotificationPopups from "./widget/NotificationPopups"
import NotificationHistory from "./widget/NotificationHistory"
import VolumePopup from "./widget/VolumePopup"
import { createState } from "ags"

export const [dashboardVisible, setDashboardVisible] = createState(false)
export const [weatherVisible, setWeatherVisible] = createState(false)
export const [todoVisible, setTodoVisible] = createState(false)
export const [calendarVisible, setCalendarVisible] = createState(false)
export const [notifHistoryVisible, setNotifHistoryVisible] = createState(false)
export const [volumeVisible, setVolumeVisible] = createState(false)

function closeAllPopups(): void {
  setDashboardVisible(false)
  setWeatherVisible(false)
  setTodoVisible(false)
  setCalendarVisible(false)
  setNotifHistoryVisible(false)
  setVolumeVisible(false)
}

// Toggle one popup, closing any other popups that are open
export function togglePopup(visible: () => boolean, setVisible: (v: boolean) => void): void {
  const next = !visible()
  closeAllPopups()
  if (next) setVisible(true)
}

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.filter((m: any) => m.get_geometry().x > 0).map(Bar)
    Dashboard(monitors[0])
    WeatherPopup(monitors[0])
    TodoPopup(monitors[0])
    CalendarPopup(monitors[0])
    NotificationPopups(monitors[0])
    NotificationHistory(monitors[0])
    VolumePopup(monitors[0])
  },
})
