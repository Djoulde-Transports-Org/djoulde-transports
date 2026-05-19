# djoulde-transports

Monorepo for **Djoulde Transports**: **Rails** at the repository root and **SvelteKit** in `frontend/` (the `frontend/` app is added in later tickets).

## Ticket-driven implementation

Implementation work is tracked in [`docs/tickets/00-INDEX.md`](../docs/tickets/00-INDEX.md) (execution order and links to each ticket spec).

## Repository layout

- **Rails** — application code lives at the **repository root** (there is **no** `backend/` folder).
- **`frontend/`** — SvelteKit application (scaffolded per ticket 13).
- **`../docs/tickets/`** — Markdown specs for each ticket (sibling folder next to this repository).

## Local dev workflow (ticket 06)

GNU Make targets wrap the most common `docker compose` invocations. Run `make help` to see the full list.

| Target               | What it does                                                       |
| -------------------- | ------------------------------------------------------------------ |
| `make dev`           | Install deps, prep DB, start mysql + redis + rails + proxy + frontend |
| `make up-detached`   | Start the same stack in the background                             |
| `make down`          | Stop and remove services                                           |
| `make clean`         | Stop containers and remove orphans                                 |
| `make logs`          | Tail rails + proxy logs                                            |
| `make build`         | Rebuild the rails image                                            |
| `make setup`         | Bring deps up, install gems, run `db:prepare` (idempotent)          |
| `make install_deps_rails` | Install Rails application dependencies (bundle)               |
| `make console`       | `bundle exec rails console` inside the running rails container     |
| `make bash`          | Bash shell inside the running rails container                      |
| `make rspec [PATH]`  | Run specs; pass paths after the target                             |
| `make rubocop`       | Run rubocop                                                        |
| `make vitest [PATH]` | Run Vitest in the frontend container (ticket 13+)                  |

Path forwarding examples:

```bash
make rspec                                       # full suite
make rspec spec/requests/health_spec.rb          # single file
make rspec spec/requests                         # directory
make vitest spec/frontend/components/foo.test.ts # SvelteKit (ticket 13+)
```

Requires GNU Make. macOS ships `/usr/bin/make` 3.81+, which is sufficient.

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

## OAuth applications (ticket 08)

The project uses [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) as an OAuth 2 provider, mounted at `/oauth` and pre-routed by the proxy.

- **Mode:** `api_only` — token endpoints only (`/oauth/token`, `/oauth/revoke`, `/oauth/introspect`). No HTML views. Admin UI for OauthApplications comes from Active Admin (ticket 12).
- **Custom application class:** `app/models/oauth_application.rb`. Doorkeeper uses it via `Doorkeeper.config.application_class = "OauthApplication"`.
- **Polymorphic owner:** every application belongs to an `owner` via `owner_type` + `owner_id`. A unique index on `[owner_type, owner_id]` enforces *one OauthApplication per owner*. The first (and currently only) owner type will be `User` once ticket 09 lands.
- **Custom columns:** `owner_type`, `owner_id`, `created_by_id`, `calls_count` (default 0, not null), `last_used_at`, `discarded_at`, `discarded_by_id` — all added in a follow-up migration so Doorkeeper's generated schema migration stays untouched.
- **Grant flows enabled:** `password` (SPA login, ticket 09) and `client_credentials` (service-to-service callers).

### Deferred to later tickets

- `User` model and the `has_one :oauth_application, as: :owner` association — ticket 09.
- FK constraints from `oauth_applications.created_by_id` / `discarded_by_id` to `users` — ticket 09 (added alongside the User migration).
- `resource_owner_from_credentials` and `resource_owner_authenticator` implementations — ticket 09. Both currently return `nil`, so password-grant token requests return 401 until login lands.
- `include Discardable` in the OauthApplication model — pending ticket 07 reaching master. Columns already exist on the table, so it's a one-line add.
- Grape `before` hook that resolves `doorkeeper_token.application`, increments `calls_count`, and stamps `last_used_at` — ticket 11.
- Active Admin screen for OauthApplications — ticket 12.

## Reverse proxy (ticket 05)

The `proxy` service (nginx 1.27-alpine, config in [`proxy/nginx.conf`](./proxy/nginx.conf)) is the single public entry point.

- **Public URL:** `http://localhost:8080`
- **Path table:**
  - `/up`, `/api`, `/oauth`, `/admin`, `/rails/active_storage` → Rails (`rails:3000`)
  - everything else → SvelteKit frontend (`frontend:5173`)

The `rails` service no longer publishes port 3000 to the host. Hit Rails through the proxy at `http://localhost:8080`, or attach via `docker compose run --rm rails bundle exec ...` for CLI tasks.

**Expected during early tickets:** `http://localhost:8080/` returns **502** until ticket 13 stands up the SvelteKit frontend. The four Rails prefixes return **404** until their owning tickets land (`/api` ticket 11, `/oauth` ticket 08, `/admin` ticket 12).

### Doorkeeper redirect URIs (ticket 08)

When ticket 08 registers OAuth applications, redirect URIs **must** use the public proxy URL (e.g. `http://localhost:8080/oauth/callback`), **never** the Docker-internal hostname (`http://rails:3000/...`). Browsers can't reach the internal hostname and the redirect will fail.

### Production posture

- TLS terminates at the proxy. Rails runs with `config.assume_ssl = true` and `config.force_ssl = true` (see `config/environments/production.rb`).
- `config.action_dispatch.trusted_proxies` (in `config/application.rb`) trusts the docker bridge ranges so `request.remote_ip` reports the real client behind nginx's `X-Forwarded-For`.
- `APP_HOST` controls the production `config.hosts` entry (see `config/application.yml.example`).

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
