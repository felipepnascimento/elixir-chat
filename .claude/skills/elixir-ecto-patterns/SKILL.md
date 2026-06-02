---
name: elixir-ecto-patterns
description: Elixir, Ecto, and PubSub patterns for ElixirChat. Load at the start of any backend agent run that touches contexts, schemas, migrations, or PubSub.
---

# Elixir & Ecto Patterns Skill — ElixirChat

## When to activate

Load this skill at the start of every run that touches:
- `lib/elixir_chat/*.ex` or `lib/elixir_chat/**/*.ex`
- `priv/repo/migrations/*.exs`
- `lib/elixir_chat/application.ex`

---

## Current project state

| Item | Value |
|------|-------|
| PubSub name | `ElixirChat.PubSub` |
| Chat topic | `"chat:lobby"` |
| Broadcast event | `{:new_message, %Message{}}` |
| Message limit | `50` (in `Chat.list_messages/0`) |
| DB adapter | `Ecto.Adapters.SQLite3` |
| Migration command | `docker compose run --rm app mix ecto.gen.migration <name>` |

---

## Context pattern

All business logic lives in context modules under `lib/elixir_chat/`. Follow this structure:

```elixir
defmodule ElixirChat.SomeContext do
  import Ecto.Query
  alias ElixirChat.Repo
  alias ElixirChat.SomeContext.SomeSchema

  # Public API — always {:ok, struct} | {:error, changeset}
  def list_things do
    SomeSchema
    |> order_by([s], asc: s.inserted_at)
    |> Repo.all()
  end

  def get_thing!(id), do: Repo.get!(SomeSchema, id)

  def create_thing(attrs) do
    %SomeSchema{}
    |> SomeSchema.changeset(attrs)
    |> Repo.insert()
  end

  def update_thing(%SomeSchema{} = thing, attrs) do
    thing
    |> SomeSchema.changeset(attrs)
    |> Repo.update()
  end

  def delete_thing(%SomeSchema{} = thing), do: Repo.delete(thing)
end
```

---

## Changeset pattern

```elixir
def changeset(struct, attrs) do
  struct
  |> cast(attrs, [:field1, :field2])        # only user-supplied fields
  |> validate_required([:field1])
  |> validate_length(:field2, min: 1, max: 500)
  |> validate_inclusion(:status, ["active", "inactive"])
  |> unique_constraint(:email)
end
```

**Rules:**
- Fields set programmatically (e.g. `is_agent`, `user_id`) must NOT be in `cast` — set them explicitly: `Ecto.Changeset.put_change(changeset, :is_agent, true)`
- Always access changeset fields with `Ecto.Changeset.get_field(changeset, :field)`, never `changeset[:field]`
- `Ecto.Schema` field type is always `:string` even for large text columns

---

## Query patterns

```elixir
# Filter
from(m in Message, where: m.username == ^username)

# Order + limit
Message
|> order_by([m], desc: m.inserted_at)
|> limit(50)
|> Repo.all()

# Preload association
Repo.all(from u in User, preload: [:messages])

# Count
Repo.aggregate(Message, :count, :id)

# Where with multiple conditions
from m in Message,
  where: m.is_agent == false and m.inserted_at > ^cutoff,
  order_by: [asc: m.inserted_at]
```

---

## PubSub pattern

```elixir
@topic "chat:lobby"

# Subscribe (called from LiveView mount)
def subscribe do
  Phoenix.PubSub.subscribe(ElixirChat.PubSub, @topic)
end

# Broadcast (always AFTER successful Repo operation)
def create_message(username, body, is_agent \\ false) do
  %Message{}
  |> Message.changeset(%{username: username, body: body, is_agent: is_agent})
  |> Repo.insert()
  |> case do
    {:ok, message} ->
      Phoenix.PubSub.broadcast(ElixirChat.PubSub, @topic, {:new_message, message})
      {:ok, message}
    error -> error
  end
end

# LiveView handle_info (for reference — do not edit chat_live.ex)
def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, &(&1 ++ [message]))}
end
```

---

## Migration patterns

Always generate with:
```bash
docker compose run --rm app mix ecto.gen.migration migration_name_using_underscores
```

Then edit the generated file at `priv/repo/migrations/<timestamp>_<name>.exs`.

```elixir
# Add a column
def change do
  alter table(:messages) do
    add :room, :string, default: "lobby", null: false
  end
end

# Add an index
def change do
  create index(:messages, [:username])
  create unique_index(:messages, [:email])
end

# Rename a column — use up/down instead of change
def up do
  rename table(:messages), :old_name, to: :new_name
end

def down do
  rename table(:messages), :new_name, to: :old_name
end

# Remove a column — always reversible
def change do
  alter table(:messages) do
    remove :deprecated_field, :string  # type required for reversibility
  end
end
```

---

## Supervision tree — adding a process

Add new processes to `lib/elixir_chat/application.ex` inside the `children` list:

```elixir
children = [
  ElixirChatWeb.Telemetry,
  ElixirChat.Repo,
  {DNSCluster, query: Application.get_env(:elixir_chat, :dns_cluster_query) || :ignore},
  {Phoenix.PubSub, name: ElixirChat.PubSub},
  # Add new supervised processes here, before Endpoint:
  {ElixirChat.SomeWorker, []},
  ElixirChatWeb.Endpoint
]
```

GenServer child spec must include a `name:`:
```elixir
def child_spec(opts) do
  %{
    id: __MODULE__,
    start: {__MODULE__, :start_link, [opts]},
    type: :worker,
    restart: :permanent
  }
end
```

---

## Elixir anti-patterns to avoid

```elixir
# NEVER — map access on struct
changeset[:field]       # raises — use Ecto.Changeset.get_field/2
my_struct[:field]       # raises — use my_struct.field

# NEVER — list index access
my_list[0]              # raises — use Enum.at(my_list, 0)

# NEVER — String.to_atom on user input
String.to_atom(params["key"])   # memory leak

# NEVER — rebind inside if/case
if condition do
  socket = assign(socket, :x, 1)   # this assignment is lost
end
# ALWAYS — bind the result
socket = if condition do
  assign(socket, :x, 1)
else
  socket
end

# NEVER — predicate named is_thing
def is_agent(msg), do: msg.is_agent   # wrong
# ALWAYS
def agent?(msg), do: msg.is_agent

# NEVER — else if
if a do ... else if b do ...   # invalid Elixir
# ALWAYS
cond do
  a -> ...
  b -> ...
  true -> ...
end
```
