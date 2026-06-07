// ~/.config/ags/app.ts
import app from "ags/gtk3/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import WeatherPopup from "./widget/WeatherPopup"
import { createState } from "ags"

export const [dashboardVisible, setDashboardVisible] = createState(false)
export const [weatherVisible, setWeatherVisible] = createState(false)

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.map(Bar)
    WeatherPopup(monitors[0])
  },
})
