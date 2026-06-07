// ~/.config/ags/widget/WeatherPopup.tsx
import { Astal, Gtk, Gdk } from "ags/gtk3"
import app from "ags/gtk3/app"
import { weather, WMO_ICON, WMO_DESC } from "../service/weather"
import { weatherVisible, setWeatherVisible } from "../app"

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

function dayLabel(dateStr: string, index: number): string {
  if (index === 0) return "Today"
  const d = new Date(dateStr + "T12:00:00")
  return DAYS[d.getDay()]
}

export default function WeatherPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      class="WeatherPopup"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP | RIGHT}
      visible={weatherVisible as unknown as boolean}
      application={app}
      onKeyPressEvent={(_self, event) => {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
          setWeatherVisible(false)
      }}
    >
      <box class="weather-popup" vertical>
        {weather.as(w => {
          if (!w) return []
          return [
            <box class="weather-current" spacing={12}>
              <label class="weather-icon" label={WMO_ICON[w.weatherCode] ?? "󰖐"} />
              <box vertical>
                <label class="weather-temp" label={`${w.temperature}°F`} halign={Gtk.Align.START} />
                <label class="weather-desc" label={`${WMO_DESC[w.weatherCode] ?? "Unknown"} · Colorado Springs`} halign={Gtk.Align.START} />
                <box class="weather-meta" spacing={6}>
                  <label label={`󰔏 ${w.apparentTemperature}°F`} />
                  <label label="·" class="weather-sep" />
                  <label label={`󰖝 ${w.windSpeed} mph`} />
                  <label label="·" class="weather-sep" />
                  <label label={`󰖐 ${w.humidity}%`} />
                </box>
              </box>
            </box>,
            <label class="weather-forecast-label" label="5-DAY FORECAST" halign={Gtk.Align.START} />,
            <box class="weather-forecast" spacing={6} homogeneous>
              {w.forecast.map((day, i) => (
                <box class="forecast-day" vertical spacing={4}>
                  <label class="forecast-name" label={dayLabel(day.date, i)} />
                  <label class="forecast-icon" label={WMO_ICON[day.weatherCode] ?? "󰖐"} />
                  <label class="forecast-hi" label={`${day.maxTemp}°`} />
                  <label class="forecast-lo" label={`${day.minTemp}°`} />
                </box>
              ))}
            </box>
          ]
        })}
      </box>
    </window>
  )
}
