// ~/.config/ags/service/weather.ts
import { createState } from "ags"
import { execAsync } from "ags/process"
import { interval } from "ags/time"

export interface DayForecast {
  date: string
  weatherCode: number
  maxTemp: number
  minTemp: number
}

export interface WeatherData {
  temperature: number
  apparentTemperature: number
  humidity: number
  windSpeed: number
  weatherCode: number
  forecast: DayForecast[]
}

// ZIP 80921 → Colorado Springs: 39.02°N, 104.77°W
const URL =
  "https://api.open-meteo.com/v1/forecast" +
  "?latitude=39.02&longitude=-104.77" +
  "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m" +
  "&daily=weather_code,temperature_2m_max,temperature_2m_min" +
  "&temperature_unit=fahrenheit&wind_speed_unit=mph" +
  "&forecast_days=5&timezone=America%2FDenver"

export const WMO_ICON: Record<number, string> = {
  0: "󰖙", 1: "󰖙", 2: "󰖕", 3: "󰖐",
  45: "󰖑", 48: "󰖑",
  51: "󰖗", 53: "󰖗", 55: "󰖗",
  61: "󰖖", 63: "󰖖", 65: "󰖖",
  71: "󰼶", 73: "󰼶", 75: "󰼶", 77: "󰼶",
  80: "󰖗", 81: "󰖗", 82: "󰖗",
  85: "󰼶", 86: "󰼶",
  95: "󰖓", 96: "󰖓", 99: "󰖓",
}

export const WMO_DESC: Record<number, string> = {
  0: "Clear Sky", 1: "Mainly Clear", 2: "Partly Cloudy", 3: "Overcast",
  45: "Foggy", 48: "Rime Fog",
  51: "Light Drizzle", 53: "Drizzle", 55: "Heavy Drizzle",
  61: "Light Rain", 63: "Rain", 65: "Heavy Rain",
  71: "Light Snow", 73: "Snow", 75: "Heavy Snow", 77: "Snow Grains",
  80: "Light Showers", 81: "Showers", 82: "Heavy Showers",
  85: "Snow Showers", 86: "Heavy Snow Showers",
  95: "Thunderstorm", 96: "Thunderstorm + Hail", 99: "Severe Thunderstorm",
}

function parse(json: string): WeatherData {
  const d = JSON.parse(json)
  const c = d.current
  const daily = d.daily
  const forecast: DayForecast[] = (daily.time as string[]).map((date: string, i: number) => ({
    date,
    weatherCode: daily.weather_code[i],
    maxTemp: Math.round(daily.temperature_2m_max[i]),
    minTemp: Math.round(daily.temperature_2m_min[i]),
  }))
  return {
    temperature: Math.round(c.temperature_2m),
    apparentTemperature: Math.round(c.apparent_temperature),
    humidity: Math.round(c.relative_humidity_2m),
    windSpeed: Math.round(c.wind_speed_10m),
    weatherCode: c.weather_code,
    forecast,
  }
}

async function fetchWeather(): Promise<WeatherData | null> {
  try {
    const out = await execAsync(["curl", "-sf", URL])
    return parse(out)
  } catch (e) {
    console.error("weather fetch failed:", e)
    return null
  }
}

export const [weather, setWeather] = createState<WeatherData | null>(null)

// Fetch immediately then every 10 minutes
fetchWeather().then(d => setWeather(d))
interval(600000, () => fetchWeather().then(d => setWeather(d)))
