// ~/.config/ags/widget/Weather.tsx
import { weather, WMO_ICON } from "../service/weather"
import { weatherVisible, setWeatherVisible } from "../app"

export default function Weather() {
  return (
    <button
      class="weather-btn"
      onClicked={() => setWeatherVisible(!weatherVisible())}
      visible={weather.as(w => w !== null)}
    >
      <label
        label={weather.as(w =>
          w ? `${WMO_ICON[w.weatherCode] ?? "󰖐"} ${w.temperature}°F` : ""
        )}
      />
    </button>
  )
}
