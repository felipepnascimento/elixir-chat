---
name: phoenix-liveview-ui
description: UI patterns, component snippets, and theme variables for the ElixirChat Phoenix LiveView app. Load this at the start of any run that touches templates, CSS, or JS hooks.
---

# Phoenix LiveView UI Skill — ElixirChat

## When to activate

Load this skill whenever you are editing:
- `lib/elixir_chat_web/live/*.html.heex`
- `lib/elixir_chat_web/components/*.ex`
- `assets/css/app.css`
- `assets/js/app.js`

---

## Theme variables (from app.css)

Both light and dark themes use these daisyUI semantic classes. Always prefer semantic classes over hardcoded OKLCH values.

| Class | Light | Dark |
|-------|-------|------|
| `bg-base-100` | white (#f8f8f8) | dark navy |
| `bg-base-200` | light gray | darker navy |
| `bg-base-300` | medium gray | darkest navy |
| `text-base-content` | near-black | near-white |
| `bg-primary` | orange | purple |
| `text-primary-content` | light | light |
| `bg-secondary` | gray-blue | purple (same as primary) |
| `bg-error` | red | red |

Dark mode is applied via `data-theme="dark"` on `<html>`. Custom variant in CSS: `@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *))`.

---

## Component patterns

### Message bubble (existing pattern in chat_live.html.heex)

```heex
<div class={["chat", if(msg.username == @username, do: "chat-end", else: "chat-start")]}>
  <div class="chat-header opacity-60 text-xs mb-1">
    <%= if msg.is_agent do %>
      🤖 {msg.username}
    <% else %>
      {msg.username}
    <% end %>
  </div>
  <div class={[
    "chat-bubble",
    if(msg.username == @username, do: "chat-bubble-primary", else: ""),
    if(msg.is_agent, do: "chat-bubble-secondary", else: "")
  ]}>
    {msg.body}
  </div>
  <div class="chat-footer opacity-40 text-xs mt-1">
    {Calendar.strftime(msg.inserted_at, "%H:%M")}
  </div>
</div>
```

### Send button (existing pattern)

```heex
<button type="submit" class="btn btn-primary">
  <.icon name="hero-paper-airplane" class="w-5 h-5" />
</button>
```

### Join card (existing pattern)

```heex
<div class="min-h-screen flex items-center justify-center bg-base-200">
  <div class="card w-80 bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title text-2xl font-bold mb-4">Elixir Chat</h2>
      <form phx-submit="set_username">
        <div class="form-control gap-3">
          <input type="text" name="username" placeholder="Your name..."
            class="input input-bordered w-full" autofocus required />
          <button type="submit" class="btn btn-primary w-full">Join</button>
        </div>
      </form>
    </div>
  </div>
</div>
```

### Navbar (existing pattern)

```heex
<div class="navbar bg-base-100 shadow px-4">
  <div class="flex-1">
    <span class="text-xl font-bold">Elixir Chat</span>
  </div>
  <div class="flex-none">
    <div class="badge badge-primary badge-lg">{@username}</div>
  </div>
</div>
```

### Colocated JS hook (inline in HEEx)

```heex
<input id="my-input" phx-hook=".CharCounter" type="text" />
<script :type={Phoenix.LiveView.ColocatedHook} name=".CharCounter">
  export default {
    mounted() {
      this.el.addEventListener("input", e => {
        const counter = document.getElementById("char-count")
        if (counter) counter.textContent = this.el.value.length
      })
    }
  }
</script>
```

### External JS hook (in assets/js/app.js)

```js
const MyHook = {
  mounted() { /* setup */ },
  updated() { /* re-run on server update */ },
  destroyed() { /* cleanup */ }
}

// Then add to LiveSocket:
const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...colocatedHooks, ScrollBottom, MyHook }
})
```

### Smooth transition utility

```heex
<div class="transition-all duration-200 ease-in-out hover:opacity-80">
  ...
</div>
```

### LiveView loading variants

```heex
<button class="btn btn-primary phx-submit-loading:opacity-50 phx-submit-loading:cursor-wait">
  Send
</button>
```

---

## LiveView streams — correct pattern

Always use streams for collections. Never assign a list directly for rendering.

```elixir
# In LiveView mount:
|> stream(:messages, Chat.list_messages())

# In handle_info:
|> stream_insert(:messages, message)
```

```heex
<%!-- In template: --%>
<div id="messages" phx-update="stream">
  <div :for={{id, msg} <- @streams.messages} id={id}>
    {msg.body}
  </div>
</div>
```

---

## LiveView lifecycle reminder

The `ScrollBottom` hook in `app.js` auto-scrolls `#messages` on mount and update. When adding new content to the messages container, verify the hook still fires by keeping `id="messages"` and `phx-hook="ScrollBottom"` on the container element.
