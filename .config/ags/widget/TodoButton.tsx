// ~/.config/ags/widget/TodoButton.tsx
import { With } from "ags"
import { todoVisible, setTodoVisible } from "../app"
import { todayCount } from "../service/todos"

export default function TodoButton() {
  return (
    <button
      class="todo-button"
      onClicked={() => setTodoVisible(!todoVisible())}
    >
      <box spacing={2}>
        <label class="todo-icon" label="󰄬" />
        <With value={todayCount}>
          {(n: number) => (
            <label class="todo-badge" label={String(n)} visible={n > 0} />
          )}
        </With>
      </box>
    </button>
  )
}
