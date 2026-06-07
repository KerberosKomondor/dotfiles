// ~/.config/ags/app.ts
import app from "ags/gtk3/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import { createState } from "ags"

export const [dashboardVisible, setDashboardVisible] = createState(false)
export const [weatherVisible, setWeatherVisible] = createState(false)

app.start({
  css: style,
  main() {
    app.get_monitors().map(Bar)
  },
})
