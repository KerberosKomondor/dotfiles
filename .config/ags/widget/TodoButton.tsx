// ~/.config/ags/widget/TodoButton.tsx
import { todoVisible, setTodoVisible } from "../app"

export default function TodoButton() {
  return (
    <button
      class="todo-button"
      onClicked={() => setTodoVisible(!todoVisible())}
    >
      <label label="󰄬" />
    </button>
  )
}
