# Elixir Chat — Agent Guide

## Overview

Real-time chat in Elixir/Phoenix with AI agents participating in conversations. The project is evolved incrementally via instructions to the agent.

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | Phoenix 1.8 + LiveView |
| Realtime | Phoenix PubSub |
| DB | SQLite via `ecto_sqlite3` |
| AI Agents | Anthropic API (via `req`) |
| Identity | Username typed on entry (no auth) |

## Running (always via Docker)

```bash
# Initial setup (first time)
docker compose run --rm app mix deps.get
docker compose run --rm app mix ecto.create
docker compose run --rm app mix ecto.migrate

# Start the server
docker compose up

# Run tests
docker compose run --rm app mix test

# Generate migration
docker compose run --rm app mix ecto.gen.migration migration_name
```

## Relevant structure

```
lib/
  elixir_chat/
    chat.ex              # Main context: list_messages, create_message, subscribe
    chat/
      message.ex         # Ecto schema: username, body, is_agent, timestamps
  elixir_chat_web/
    live/
      chat_live.ex       # Main LiveView
      chat_live.html.heex
    router.ex            # Root route → ChatLive
priv/repo/migrations/    # Ecto migrations
assets/js/app.js         # JS hooks (ScrollBottom)
```

## Required conventions

- **Always LiveView** for new screens — no HTML controllers.
- **Always PubSub** for real-time — `ElixirChat.PubSub`, topic `"chat:lobby"`.
- **Always Ecto contexts** — business logic in `lib/elixir_chat/`, never inside LiveView.
- **SQLite** — no PostgreSQL. Use `Ecto.Adapters.SQLite3`.
- **Docker** — all mix commands run via `docker compose run --rm app mix ...`.
- No unnecessary comments in code.
- **English only** — all code, comments, strings, and documentation must be in English.

## AI agents in the product

AI agents have `is_agent: true` and username prefixed with `agent:` (e.g. `agent:assistant`). They are Elixir processes (GenServer/Task) that call the Anthropic API when triggered via PubSub.

## Environment variables

- `ANTHROPIC_API_KEY` — required for AI agents (Phase 2+)
- `SECRET_KEY_BASE` — generated at build time for production

## Roadmap

- [x] Phase 1: Basic chat with two users, persisted messages, real-time
- [ ] Phase 2: AI agent in chat (Claude bot via Anthropic API)
- [ ] Phase 3: Chat rooms
- [ ] Phase 4: Agent with conversation memory
- [ ] Phase 5: Multiple agents with personas
- [ ] Phase 6: Online presence, "typing..." indicator
