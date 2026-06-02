---
name: commit-convention
description: Shared skill for generating git commit message suggestions. Load this at the end of any agent run that modifies files. All agents in this project must follow this convention.
---

# Commit Convention Skill — ElixirChat

## When to activate

At the end of every agent interaction that modifies at least one file, produce a `## Suggested commit` block in the response.

---

## Format rules

- **1 line only** — no body, no footer, no trailers
- **Max 72 characters**
- **No period** at the end
- **English only**
- Never include `Co-authored-by`, `Signed-off-by`, or any other git trailer

---

## Style: Conventional Commits

```
type(scope): description in imperative present tense
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New visible feature or behavior |
| `fix` | Bug fix or incorrect behavior corrected |
| `style` | Visual/layout change with no logic change |
| `refactor` | Code restructured, no behavior change |
| `chore` | Config, tooling, dependencies, gitignore |
| `docs` | Documentation only (CLAUDE.md, README, comments) |

### Scopes for this project

| Scope | Covers |
|-------|--------|
| `ui` | HEEx templates, CSS, JS hooks (frontend agent) |
| `chat` | Chat context, PubSub, message logic (backend agent) |
| `backend` | Ecto schemas, migrations, contexts |
| `agents` | Agent definition files in `.claude/agents/` |
| `config` | mix.exs, docker-compose, gitignore, app config |

---

## Examples

```
feat(ui): add character counter below message input
fix(ui): correct chat bubble alignment on mobile
style(ui): increase spacing between join input and button
feat(chat): broadcast new message via PubSub on insert
fix(backend): validate message body length in changeset
chore(config): ignore SQLite db files in gitignore
docs(agents): add commit convention to frontend agent report
```

---

## Output format

Always place this block at the very end of the agent response, after `## How to verify`:

```
## Suggested commit
`type(scope): description`
```

One backtick-wrapped line. No alternatives, no explanation — just the best single commit message for the changes made.
