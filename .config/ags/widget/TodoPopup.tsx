// ~/.config/ags/widget/TodoPopup.tsx
import { Astal, Gtk, Gdk } from "ags/gtk3"
import app from "ags/gtk3/app"
import { createState, With } from "ags"
import { todoVisible, setTodoVisible } from "../app"
import {
  TodoItem, getCurrentWeekDates, today, getDayName,
  getTodosForDate, saveTodosForDate, initDayIfNeeded, refreshBadge,
} from "../service/todos"

export default function TodoPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor
  const weekDates = getCurrentWeekDates()
  const todayStr = today()

  const [selectedDate, setSelectedDate] = createState(todayStr)
  const [items, setItems] = createState<TodoItem[]>([])
  const [showAdd, setShowAdd] = createState(false)

  function loadDay(date: string): void {
    initDayIfNeeded(date)
    setItems(getTodosForDate(date))
    setShowAdd(false)
  }

  function toggleItem(text: string): void {
    const date = selectedDate()
    const current = getTodosForDate(date)
    const idx = current.findIndex(it => it.text === text)
    if (idx === -1) return
    current[idx].done = !current[idx].done
    saveTodosForDate(date, current)
    setItems([...current])
    refreshBadge()
  }

  function deleteItem(text: string): void {
    const date = selectedDate()
    const current = getTodosForDate(date)
    const updated = current.filter(it => it.text !== text)
    saveTodosForDate(date, updated)
    setItems(updated)
    refreshBadge()
  }

  // Load today on first open
  loadDay(todayStr)

  return (
    <window
      class="TodoPopup"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | LEFT}
      visible={todoVisible.as(v => v)}
      application={app}
      onKeyPressEvent={(_self, event) => {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
          setTodoVisible(false)
      }}
    >
      <box class="todo-popup" vertical spacing={0}>

        {/* Day tabs */}
        <With value={selectedDate}>
          {(active: string) => (
            <box class="todo-tabs" spacing={2}>
              {weekDates.map(date => {
                const hasItems = getTodosForDate(date).length > 0
                const isToday = date === todayStr
                const isActive = date === active
                let cls = "todo-tab"
                if (isActive) cls += " active"
                else if (hasItems) cls += " has-items"
                else if (isToday) cls += " today"
                return (
                  <button
                    class={cls}
                    onClicked={() => {
                      setSelectedDate(date)
                      loadDay(date)
                    }}
                  >
                    <label label={getDayName(date)} />
                  </button>
                )
              })}
            </box>
          )}
        </With>

        <box class="todo-divider" />

        {/* Item list */}
        <With value={items}>
          {(list: TodoItem[]) => (
            <box vertical spacing={2} class="todo-list">
              {list.length === 0
                ? <label class="todo-empty" label="Nothing here" halign={Gtk.Align.CENTER} />
                : list.map((item, i) => (
                    <box class={`todo-item${item.done ? " done" : ""}`} spacing={4}>
                      <button class="todo-check" onClicked={() => toggleItem(item.text)}>
                        <label label={item.done ? "☑" : "☐"} />
                      </button>
                      <label class="todo-text" label={item.text} hexpand halign={Gtk.Align.START} />
                      <button class="todo-delete" onClicked={() => deleteItem(item.text)}>
                        <label label="✕" />
                      </button>
                    </box>
                  ))
              }
            </box>
          )}
        </With>

        {/* Add button placeholder — full add flow in Task 5 */}
        <With value={showAdd}>
          {(adding: boolean) => adding
            ? <label label="" />
            : (
              <button class="todo-add-btn" onClicked={() => setShowAdd(true)}>
                <label label="＋" />
              </button>
            )
          }
        </With>

      </box>
    </window>
  )
}
