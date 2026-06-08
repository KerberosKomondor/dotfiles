// ~/.config/ags/widget/TodoButton.tsx
import { Gtk } from "ags/gtk4"
import { todoVisible, setTodoVisible } from "../app"
import { todayCount } from "../service/todos"

export default function TodoButton() {
  return (
    <overlay>
      <button class="todo-button" onClicked={() => setTodoVisible(!todoVisible())}>
        <label class="todo-icon" label="󰄬" />
      </button>
      <label
        $type="overlay"
        class="todo-badge"
        halign={Gtk.Align.END}
        valign={Gtk.Align.START}
        visible={todayCount.as(n => n > 0)}
        label={todayCount.as(n => String(n))}
      />
    </overlay>
  )
}
