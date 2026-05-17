# djoulde-transports

Monorepo for **Djoulde Transports**: **Rails** at the repository root and **SvelteKit** in `frontend/` (the `frontend/` app is added in later tickets).

## Ticket-driven implementation

Implementation work is tracked in [`docs/tickets/00-INDEX.md`](../docs/tickets/00-INDEX.md) (execution order and links to each ticket spec).

## Repository layout

- **Rails** — application code lives at the **repository root** (there is **no** `backend/` folder).
- **`frontend/`** — SvelteKit application (scaffolded per ticket 13).
- **`../docs/tickets/`** — Markdown specs for each ticket (sibling folder next to this repository).

## Docker Compose

[`docker-compose.yml`](./docker-compose.yml) is a **skeleton only**: it reserves the service names `mysql`, `redis`, `rails`, `frontend`, and `proxy` for the full dev stack. It is **not** complete orchestration yet; details are filled in starting with ticket 02.

## Cursor agents

Before large edits across the tree, set the agent workspace to this repository (for example **cursor-app-control** → **move_agent_to_root** with path `/Users/alimouranabalde/Documents/djoulde-transports`).
