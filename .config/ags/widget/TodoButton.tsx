// ~/.config/ags/widget/TodoButton.tsx
import { todoVisible, setTodoVisible } from "../app"
import { todayCount } from "../service/todos"

export default function TodoButton() {
  return (
    <button class="todo-button" onClicked={() => setTodoVisible(!todoVisible())}>
      <label
        class="todo-icon"
        use_markup={true}
        label={todayCount.as(n => n > 0
          ? `󰄬 <span foreground="#282a36" background="#ff79c6" size="small" weight="bold"> ${n} </span>`
          : "󰄬"
        )}
      />
    </button>
  )
}
