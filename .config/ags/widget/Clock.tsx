// ~/.config/ags/widget/Clock.tsx
import { createPoll } from "ags/time"

export default function Clock() {
  const time = createPoll("", 60000, ["date", "+%a %b %d  %I:%M %p"])

  return <label class="clock" label={time} />
}
