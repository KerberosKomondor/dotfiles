// ~/.config/ags/app.ts
import app from "ags/gtk3/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import WeatherPopup from "./widget/WeatherPopup"
import Dashboard from "./widget/Dashboard"
import TodoPopup from "./widget/TodoPopup"
import { createState } from "ags"

export const [dashboardVisible, setDashboardVisible] = createState(false)
export const [weatherVisible, setWeatherVisible] = createState(false)
export const [todoVisible, setTodoVisible] = createState(false)

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.map(Bar)
    Dashboard(monitors[0])
    WeatherPopup(monitors[0])
    TodoPopup(monitors[0])
  },
})
