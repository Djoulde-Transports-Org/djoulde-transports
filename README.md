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

## Domain models (ticket 10)

Business models live in `app/models/`. Every business model includes `Discardable` (soft delete via `discard`) and is `audited` (full change history in the `audits` table via [`audited`](https://github.com/collectiveidea/audited)). **No `dependent: :destroy`** on business aggregates: associations either `restrict_with_error` or are detached via `discard` cascades in service objects (ticket 11+).

| Model              | Soft delete | Audited | Notes                                                                                                  |
| ------------------ | ----------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `Truck`            | yes         | yes     | `plate_number` unique; `status` enum (`active` / `out_of_service`)                                     |
| `Route`            | yes         | yes     | Unique `(origin, destination)` pair; `rate` is the **per-liter** billing rate (GNF) for that route     |
| `Trip`             | yes         | yes     | `belongs_to :truck, :route`; optional `:driver` (User); `status` enum (scheduled → cancelled)          |
| `DeliveryNote`     | yes         | yes     | One per trip (unique `trip_id`); unique `number`; gasoline / diesel liters; `product` derived          |
| `Maintenance`      | yes         | yes     | `belongs_to :truck`; optional `:performed_by` (User); `kind` enum                                      |
| `Document`         | yes         | yes     | Polymorphic `:documentable`; `has_one_attached :file` (Active Storage)                                 |
| `BillingStatement` | yes         | yes     | One fleet-wide statement per calendar month (unique `month`); HT / TVA / TTC totals; `has_associated_audits` |
| `BillingLineItem`  | yes         | yes     | One per trip on a statement; fat snapshot for invoice rendering (see below)                            |

### Billing model

- Billing is **monthly and fleet-wide**: one `BillingStatement` per calendar month (`month` = first day of that month, unique). No `BillingPeriod` table — the period is the statement.
- **`Route.rate` is per liter**, scoped by `(origin, destination)`. Stored as a whole-GNF integer (no subunits in Guinean franc). Rates are expected to be stable for years; updates apply going forward.
- Every billable `Trip` has a `DeliveryNote` recording `quantity_gasoline_liters` and `quantity_diesel_liters`. The derived `product` is `:gasoline`, `:diesel`, or `:both`.
- A statement aggregates every `Trip` whose `actual_start_at` falls inside the month. `BillingLineItem.from_trip(trip, billing_statement:)` builds the line by snapshotting **everything needed to render the invoice row**, so historical bills don't change if a trip / route / delivery note is corrected later:
  - `started_on`, `delivery_note_number`, `origin`, `destination`
  - `quantity_gasoline_liters`, `quantity_diesel_liters`
  - `rate` (snapshot of `route.rate`)
  - `amount` = `(qty_gasoline + qty_diesel) × rate` (HT)
  - `tva` = `amount × 0.18` (`BillingLineItem::TVA_RATE`, Guinea statutory VAT)
- **Statement totals** are HT / TVA / TTC. `BillingStatement#recalculate_total!` writes all three:
  - `total_amount` = Σ line `amount` (HT)
  - `total_tva` = Σ line `tva`
  - `grand_total` = `total_amount + total_tva` (TTC, what the client pays)
- **Issue window:** `issued_on` must fall between day 1 and day 10 of the month *after* `month` (`BillingStatement#issue_window`). Validated on save.
- `BillingStatement.due_for_issue(today)` returns draft statements whose billed month has ended. The job that creates a draft statement on the 1st of each month and materializes line items via `BillingLineItem.from_trip` lands in ticket 11.

### Implementation notes

- **Active Storage** is installed (`active_storage_blobs` / `attachments` / `variant_records`). Documents attach files via `has_one_attached :file`.
- **Audited YAML coder:** `config/initializers/audited.rb` registers `Date`, `Time`, `ActiveSupport::TimeWithZone`, `BigDecimal`, etc. on `ActiveRecord.yaml_column_permitted_classes` so `audited_changes` (stored as MySQL TEXT) can round-trip those value types under Psych safe-load.
- **No hard deletes**: service-layer code calls `record.discard`. `dependent: :restrict_with_error` blocks deletes of aggregates that still have children; cascades land in ticket 11.

### Deferred to later tickets

- Grape endpoints exposing these models — ticket **11**.
- Service object / job that creates a draft `BillingStatement` for last month on day 1 and materializes one `BillingLineItem` per trip — ticket **11**.
- Active Admin screens for trucks, routes, trips, maintenance, documents, and billing — ticket **12**.
- Role-based authorization on endpoints (e.g., `driver_readonly` cannot edit) — ticket **14**.

## Auth stack (ticket 09)

User authentication is **Devise** + a custom **Grape** login endpoint that issues **Doorkeeper** tokens. Roles via **Rolify**.

- **User model** (`app/models/user.rb`) enables five Devise modules: `database_authenticatable`, `confirmable`, `lockable`, `trackable`, `recoverable`. Auto-confirmed in dev/test for spec ergonomics.
- **Custom login:** `POST /api/v1/sessions` (Grape). Returns a Doorkeeper access token tied to the user's `OauthApplication`. Doorkeeper's `/oauth/token` password grant is intentionally disabled (see ticket 09 "do not").
- **One-app-per-user contract:** users without an `OauthApplication` get **403** with stable error code `"api_access_denied_no_application"`. Other documented error codes from `/api/v1/sessions`: `"invalid_credentials"` (401), `"discarded"` (403), `"locked"` (403), `"unconfirmed"` (403).
- **Authenticated endpoints** (e.g. `GET /api/v1/me`): bearer token required; token's `application.owner` must match `doorkeeper_token.resource_owner` (same User). Otherwise 401.
- **Rolify** seeds 5 roles in `db/seeds.rb`: `super_admin`, `dispatcher`, `billing`, `maintenance`, `driver_readonly`. Assignment via Active Admin (ticket 12) or `user.add_role(:role_name)`.
- **Mailer:** Devise sends confirmation/unlock/reset emails. Dev uses `letter_opener` (opens emails in the browser); production uses SMTP via the Figaro `SMTP_*` keys.
- **Discard cascade:** when a User is discarded, an `after_discard` callback discards their `OauthApplication` too (Discard has no `dependent: :discard`).

### Deferred to later tickets

- Grape `before` hook that increments `oauth_application.calls_count` and stamps `last_used_at` — ticket 11.
- Custom Grape endpoints for confirmation / password reset / unlock (currently driven by Devise's HTML views via email links) — possible future ticket.
- SvelteKit login screen that consumes `/api/v1/sessions` — ticket 13.
- Role-based authorization on specific endpoints — ticket 14.

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
## Soft delete (ticket 07)

The project uses the [`discard`](https://github.com/jhawthorn/discard) gem for soft deletes. Models that need soft delete include the `Discardable` concern (`app/models/concerns/discardable.rb`), which:

- Adds `Discard::Model` (gives `.kept`, `.discarded`, `#discard`, `#undiscard`).
- Registers a `before_discard` callback that stamps `discarded_by_id` from `Current.user`.

**No `default_scope { kept }`.** Callers query `.kept` / `.discarded` explicitly. Implicit scopes were considered and rejected (foot-guns around joins, counters, and Active Admin views).

`Current.user` (an `ActiveSupport::CurrentAttributes` subclass in `app/models/current.rb`) is the source of truth for "who discarded this row". Controllers that authenticate include `SetsCurrentUser` (`app/controllers/concerns/sets_current_user.rb`) once login lands in ticket 09.

### Deferred to later tickets

- Migrations adding `discarded_at` + `discarded_by_id` columns — added by ticket 08 (OauthApplication), ticket 09 (User), and ticket 10 (domain models).
- `active_for_authentication?` on `User` to block login when discarded — ticket 09.
- Cascade discard of `OauthApplication` rows when a `User` is discarded — ticket 09 via an `after_discard` callback on User (Discard has no `dependent: :discard`).

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
