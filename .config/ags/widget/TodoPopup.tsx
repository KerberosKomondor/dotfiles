// ~/.config/ags/widget/TodoPopup.tsx
import { Astal, Gtk, Gdk } from "ags/gtk3"
import app from "ags/gtk3/app"
import { createState, With } from "ags"
import { todoVisible, setTodoVisible } from "../app"
import {
  TodoItem, getCurrentWeekDates, today, getDayName, getDayLetter,
  getTodosForDate, saveTodosForDate, initDayIfNeeded, refreshBadge,
  getRecurring, saveRecurring, hasTodosFile, ALL_DAY_LETTERS,
} from "../service/todos"

export default function TodoPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor
  const weekDates = getCurrentWeekDates()
  const todayStr = today()

  const [selectedDate, setSelectedDate] = createState(todayStr)
  const [items, setItems] = createState<TodoItem[]>([])
  const [showAdd, setShowAdd] = createState(false)
  const [addMode, setAddMode] = createState<"oneoff" | "recurring">("oneoff")
  const [selectedDays, setSelectedDays] = createState<string[]>([getDayLetter(todayStr)])
  const [addText, setAddText] = createState("")

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

  function toggleDaySelection(letter: string): void {
    const current = selectedDays()
    const next = current.includes(letter)
      ? current.filter(l => l !== letter)
      : [...current, letter]
    setSelectedDays(next)
  }

  function handleAdd(text: string): void {
    if (!text.trim()) return
    const days = selectedDays()
    if (days.length === 0) return

    if (addMode() === "oneoff") {
      for (const date of weekDates) {
        if (days.includes(getDayLetter(date))) {
          initDayIfNeeded(date)
          const current = getTodosForDate(date)
          saveTodosForDate(date, [...current, { text: text.trim(), done: false }])
        }
      }
    } else {
      const current = getRecurring()
      saveRecurring([...current, { text: text.trim(), days }])
      for (const date of weekDates) {
        if (days.includes(getDayLetter(date))) {
          if (hasTodosFile(date)) {
            const content = getTodosForDate(date)
            saveTodosForDate(date, [...content, { text: text.trim(), done: false }])
          }
        }
      }
    }

    setItems(getTodosForDate(selectedDate()))
    refreshBadge()
    setShowAdd(false)
    setAddMode("oneoff")
    setSelectedDays([getDayLetter(selectedDate())])
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

        {/* Add button / form */}
        <With value={showAdd}>
          {(adding: boolean) => adding ? (
            <box vertical class="todo-add-form" spacing={6}>
              <entry
                class="todo-add-entry"
                placeholder_text="What needs doing?"
                onChanged={(self: any) => setAddText(self.text)}
                onActivate={(self: any) => {
                  handleAdd(self.text)
                  self.set_text("")
                  setAddText("")
                }}
              />
              <With value={addMode}>
                {(mode: "oneoff" | "recurring") => (
                  <box vertical spacing={4}>
                    <box spacing={4}>
                      <button
                        class={`todo-mode-btn${mode === "oneoff" ? " active" : ""}`}
                        onClicked={() => { setAddMode("oneoff"); setSelectedDays([getDayLetter(selectedDate())]) }}
                      >
                        <label label="One-off" />
                      </button>
                      <button
                        class={`todo-mode-btn${mode === "recurring" ? " active" : ""}`}
                        onClicked={() => { setAddMode("recurring"); setSelectedDays([]) }}
                      >
                        <label label="Recurring" />
                      </button>
                    </box>
                    <With value={selectedDays}>
                      {(days: string[]) => (
                        <box class="todo-day-picker" spacing={3}>
                          {mode === "oneoff"
                            ? weekDates.map(date => {
                                const letter = getDayLetter(date)
                                return (
                                  <button
                                    class={`todo-day-btn${days.includes(letter) ? " active" : ""}`}
                                    onClicked={() => toggleDaySelection(letter)}
                                  >
                                    <label label={getDayName(date).slice(0, 2)} />
                                  </button>
                                )
                              })
                            : ALL_DAY_LETTERS.map(letter => (
                                <button
                                  class={`todo-day-btn${days.includes(letter) ? " active" : ""}`}
                                  onClicked={() => toggleDaySelection(letter)}
                                >
                                  <label label={letter} />
                                </button>
                              ))
                          }
                        </box>
                      )}
                    </With>
                    <box spacing={4}>
                      <button
                        class="todo-save-btn"
                        onClicked={() => { handleAdd(addText()); setAddText("") }}
                      >
                        <label label="Add" />
                      </button>
                      <button class="todo-cancel-btn" onClicked={() => setShowAdd(false)}>
                        <label label="Cancel" />
                      </button>
                    </box>
                  </box>
                )}
              </With>
            </box>
          ) : (
            <button class="todo-add-btn" onClicked={() => setShowAdd(true)}>
              <label label="＋" />
            </button>
          )}
        </With>

      </box>
    </window>
  )
}
