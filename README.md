# djoulde-transports

Monorepo for **Djoulde Transports**: **Rails** at the repository root and **SvelteKit** in `frontend/` (the `frontend/` app is added in later tickets).

## Ticket-driven implementation

Implementation work is tracked in [`docs/tickets/00-INDEX.md`](../docs/tickets/00-INDEX.md) (execution order and links to each ticket spec).

## Repository layout

- **Rails** — application code lives at the **repository root** (there is **no** `backend/` folder).
- **`frontend/`** — SvelteKit application (scaffolded per ticket 13).
- **`../docs/tickets/`** — Markdown specs for each ticket (sibling folder next to this repository).

## Stack versions (ticket 02)

- **Ruby:** 3.4.9. The ticket's primary target was Ruby 4.0.2, which is not released; the documented fallback (3.4.9) is in use.
- **Rails:** 8.1.3
- **MySQL image:** `mysql:8.0`
- **Redis image:** `redis:7-alpine`

## Docker Compose

[`docker-compose.yml`](./docker-compose.yml) now wires `mysql`, `redis`, and `rails` as a working dev stack. `frontend` and `proxy` remain skeleton placeholders (filled in by tickets 13 and 05).

### Bring the stack up

```bash
docker compose build rails
docker compose up -d mysql redis
docker compose run --rm rails bundle exec rails db:prepare
docker compose up -d rails
```

### Verification one-liners

```bash
docker compose config                                        # validates compose file
docker compose run --rm rails bundle exec rails -v           # => Rails 8.1.x
docker compose run --rm rails bundle exec rails db:version   # => current schema version
```

### Secrets

`config/master.key` is created by `rails new` and is **gitignored**. After a fresh clone, get the key from a teammate (or regenerate credentials via `EDITOR=vi bundle exec rails credentials:edit`). The compose `rails` service does not need `RAILS_MASTER_KEY` in development; production runs will read it from the environment.

## Configuration (Figaro)

Local env is loaded by **Figaro** from `config/application.yml` (gitignored). To bootstrap a host-side workflow:

```bash
cp config/application.yml.example config/application.yml
# edit config/application.yml with real values
```

Inside docker-compose the same keys are injected via the `environment:` block on the `rails` service, so `application.yml` is only needed when running `bundle exec` directly on the host.

`config/initializers/figaro.rb` calls `Figaro.require_keys` so boot fails fast if `DATABASE_HOST`, `DATABASE_NAME`, `REDIS_URL`, or `SECRET_KEY_BASE` is missing.

## Rate limiting and CORS (ticket 04)

- **Rate limiting:** Rack::Attack is wired through `config/initializers/rack_attack.rb` and backed by `ActiveSupport::Cache::RedisCacheStore` against `REDIS_URL`. `/up` is safelisted; `POST /oauth/token` is throttled to 5 req/min/IP; `/api/*` is throttled to 300 req/min/IP. Override responses are JSON 429s.
- **CORS:** `config/initializers/cors.rb` inserts `Rack::Cors` at middleware index 0. Origins come from `CORS_ORIGINS` (CSV).

## Quality and testing (ticket 03)

Linting via RuboCop (omakase + `rubocop-rspec`):

```bash
docker compose run --rm rails bundle exec rubocop
```

Specs via RSpec (`spec/` only — no `test/` Minitest dir):

```bash
docker compose run --rm rails bundle exec rspec
```

The smoke spec at `spec/requests/health_spec.rb` hits Rails 8's built-in `/up` health route.

## Cursor agents

Before large edits across the tree, set the agent workspace to this repository (for example **cursor-app-control** → **move_agent_to_root** with path `/Users/alimouranabalde/Documents/djoulde-transports`).
