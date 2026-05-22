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

Business models live in `app/models/`. Every business model includes `Discardable` (soft delete via `discard`) and is `audited` (full change history in the `audits` table via [`audited`](https://github.com/collectiveidea/audited)). **No `dependent: :destroy`** on business aggregates: associations either `restrict_with_error` or are detached via `discard` cascades in service objects under `app/services/<resource>/discard.rb` (ticket 11).

A "truck" in the fleet is two physically distinct assets: the **head** (tractor / `Truck`) and the **tank** (trailer / `Tank`). Each has its own VIN, plate number, and registration. They're paired 1:1 (`Tank belongs_to :truck`, `Truck has_one :tank`); the pairing is effectively fixed and only swaps when one of the two is retired. Trips snapshot both `truck_id` and `tank_id` so historical reports survive a swap.

| Model              | Soft delete | Audited | Notes                                                                                                  |
| ------------------ | ----------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `Truck`            | yes         | yes     | The head/tractor. `plate_number` unique; `status` enum (`active` / `out_of_service`)                   |
| `Tank`             | yes         | yes     | The trailer. `belongs_to :truck` (NOT NULL, unique 1:1). `capacity_liters` required; status enum       |
| `Route`            | yes         | yes     | Unique `(origin, destination)` pair; `rate` is the **per-liter** billing rate (GNF) for that route     |
| `Trip`             | yes         | yes     | `belongs_to :truck, :tank, :route`; optional `:driver` (User); status enum (scheduled → cancelled). Trip's `tank.truck_id` must equal its `truck_id` (consistency validator); tank defaults to `truck.tank` on create |
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
- `BillingStatement.due_for_issue(today)` returns draft statements whose billed month has ended. `Billing::DraftMonthlyStatementJob` (recurring entry in `config/recurring.yml`, runs at 02:00 on the 1st of each month) calls `Billing::DraftMonthlyStatement` to create the prior month's draft and materialize one `BillingLineItem` per kept trip via `BillingLineItem.from_trip`. The service is idempotent per month.

### Implementation notes

- **Active Storage** is installed (`active_storage_blobs` / `attachments` / `variant_records`). Documents attach files via `has_one_attached :file`.
- **Audited YAML coder:** `config/initializers/audited.rb` registers `Date`, `Time`, `ActiveSupport::TimeWithZone`, `BigDecimal`, etc. on `ActiveRecord.yaml_column_permitted_classes` so `audited_changes` (stored as MySQL TEXT) can round-trip those value types under Psych safe-load.
- **No hard deletes**: service-layer code calls `record.discard`. `dependent: :restrict_with_error` blocks `destroy` of aggregates that still have children; soft-delete cascades live in `app/services/<resource>/discard.rb` (ticket 11) and either propagate `discard!` to children (Truck → trips/maintenances/documents; Trip → delivery_note/documents; Maintenance → documents; Tank → documents) or raise `ApplicationService::HasDependents` when a parent still has billed/used children (Route, Tank, Trip already billed, BillingStatement with kept line items, Truck while it still has a kept tank).

### Deferred to later tickets

- Active Admin screens for trucks, routes, trips, maintenance, documents, and billing — ticket **12**.
- Role-based authorization on endpoints (e.g., `driver_readonly` cannot edit) — ticket **14**.

## Grape API v1 (ticket 11)

JSON API mounted at `/api/v1` (`app/api/v1/`). Authentication is the bearer token issued by `POST /api/v1/sessions` (ticket 09). Pundit policies live in `app/policies/`; entities in `app/api/v1/entities/`.

| Resource path                                        | Verbs                            | Notes                                                        |
| ---------------------------------------------------- | -------------------------------- | ------------------------------------------------------------ |
| `/api/v1/me`                                         | GET                              | Authenticated user + roles                                   |
| `/api/v1/sessions`                                   | POST                             | Login (ticket 09)                                            |
| `/api/v1/trucks`                                     | GET, POST                        | The head/tractor. Filterable by status; admin-only mutate    |
| `/api/v1/trucks/:id`                                 | GET, PATCH, DELETE               | DELETE blocked while a kept tank is paired; otherwise cascades to trips/maintenances/documents |
| `/api/v1/tanks`                                      | GET, POST                        | The trailer. Filter `truck_id`. POST requires `truck_id` + `capacity_liters` |
| `/api/v1/tanks/:id`                                  | GET, PATCH, DELETE               | DELETE blocked if kept trips reference the tank              |
| `/api/v1/routes`                                     | GET, POST                        |                                                              |
| `/api/v1/routes/:id`                                 | GET, PATCH, DELETE               | DELETE blocked if kept trips reference the route             |
| `/api/v1/trips`                                      | GET, POST                        | Filters: `truck_id`, `tank_id`, `route_id`, `status`. `tank_id` defaults to the truck's currently paired tank |
| `/api/v1/trips/:id`                                  | GET, PATCH, DELETE               | DELETE blocked if trip is already on a billing line item     |
| `/api/v1/trips/:trip_id/delivery_note`               | GET, POST, PATCH, DELETE         | Singular nested resource (`has_one`)                          |
| `/api/v1/maintenances`                               | GET, POST                        | Filters: `truck_id`, `kind`                                  |
| `/api/v1/maintenances/:id`                           | GET, PATCH, DELETE               | DELETE cascades discard to documents                          |
| `/api/v1/documents`                                  | GET, POST                        | Polymorphic owner via `documentable_type` + `documentable_id`; multipart `file` |
| `/api/v1/documents/:id`                              | GET, PATCH, DELETE               |                                                              |
| `/api/v1/billing_statements`                         | GET, POST                        |                                                              |
| `/api/v1/billing_statements/:id`                     | GET, PATCH, DELETE               | DELETE blocked if kept line items exist                       |
| `/api/v1/billing_statements/:id/issue`               | PATCH                            | Draft → issued; runs `recalculate_total!` first              |
| `/api/v1/billing_statements/:id/mark_paid`           | PATCH                            | Issued → paid                                                |
| `/api/v1/billing_line_items`                         | GET                              | Read-only (created by the monthly billing job)               |
| `/api/v1/billing_line_items/:id`                     | GET                              |                                                              |

- **Index scoping:** every list uses `policy_scope(Model).kept`. Discarded records 404 on `GET /:id`.
- **DELETE semantics:** soft delete via `record.discard`; `Discardable`'s `before_discard` stamps `discarded_by_id` from `Current.user`. Cascades and "block" decisions live in the per-resource `Discard` service.
- **Authorization:** baseline (ticket 11) is "any authenticated user reads, only `super_admin` mutates." Ticket 14 narrows per role.
- **Error format:** `{"error": {"code": "<machine>", "message": "<human>", "details": <optional>}}`. Codes used: `unauthorized` (401), `invalid_credentials` (401), `forbidden` / `api_access_denied_no_application` / `discarded` / `locked` / `unconfirmed` (403), `not_found` (404), `conflict` (409), `validation_failed` / `has_dependents` / `invalid_argument` (422), `internal_server_error` (500).
- **Instrumentation:** every authenticated request bumps `oauth_application.calls_count` and stamps `last_used_at` in a single UPDATE (no callbacks, no `updated_at`).

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

**Expected during early tickets:** `http://localhost:8080/` returns **502** until ticket 13 stands up the SvelteKit frontend. `/admin` returns **404** until ticket 12.

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
