// ~/.config/ags/widget/DashboardButton.tsx
import { dashboardVisible, setDashboardVisible } from "../app"

export default function DashboardButton() {
  return (
    <button
      class="dashboard-button"
      onClicked={() => setDashboardVisible(!dashboardVisible())}
    >
      <label label="󰣇" />
    </button>
  )
}
