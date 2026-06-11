---
name: api-spec-pattern
description: Use when writing or editing any RSpec spec under spec/api/ (Grape endpoints and entities). Enforces the project's request- and entity-spec conventions so new specs match the existing pattern without boilerplate, with one spec file per endpoint action and full happy/unhappy-path coverage.
---

# API spec pattern

All specs that touch the Grape API live under `spec/api/` and follow the rules below. The harness wiring is already in place (see `.rspec`, `spec/rails_helper.rb`, `spec/support/json_api_requests.rb`, `spec/support/api_auth.rb`); the rules exist so you don't fight it.

## Locations

Mirror the source tree under `app/api/api/v1/`. **One spec file per endpoint file** — same name, `_spec.rb` suffix.

| Source                                                | Spec                                                       |
| ----------------------------------------------------- | ---------------------------------------------------------- |
| `app/api/api/v1/endpoints/<resource>/list.rb`         | `spec/api/v1/endpoints/<resource>/list_spec.rb`            |
| `app/api/api/v1/endpoints/<resource>/create.rb`       | `spec/api/v1/endpoints/<resource>/create_spec.rb`          |
| `app/api/api/v1/endpoints/<resource>/get.rb`          | `spec/api/v1/endpoints/<resource>/get_spec.rb`             |
| `app/api/api/v1/endpoints/<resource>/update.rb`       | `spec/api/v1/endpoints/<resource>/update_spec.rb`          |
| `app/api/api/v1/endpoints/<resource>/delete.rb`       | `spec/api/v1/endpoints/<resource>/delete_spec.rb`          |
| `app/api/api/v1/entities/<name>.rb`                   | `spec/api/v1/entities/<name>_spec.rb`                      |

Do NOT create one combined `<resource>_spec.rb`, and do not put API specs under `spec/requests/` (that path is reserved for non-API request specs like `health_spec.rb`, `rack_attack_spec.rb`). `common.rb` and `default.rb` do not get their own spec files — they are covered through the action specs.

## What the harness gives you for free

Never add any of these to a new spec:

- `require "rails_helper"` — `.rspec` already loads it.
- `type: :request` — `spec/rails_helper.rb` derives it from the `spec/api/` path.
- `Content-Type: application/json` / `.to_json` — `spec/support/json_api_requests.rb` defaults every `get/post/put/patch/delete` under `spec/api/` to `as: :json`, which serializes params and sets the header.
- Hand-rolled user / token / Authorization wiring — `spec/support/api_auth.rb` exposes `auth_setup(role:)` and `bearer_headers(token)` (see "Auth helpers" below).

If you find yourself adding any of the above, delete it.

## Endpoint specs

- `RSpec.describe` the endpoint constant directly, never a route string:
  ```ruby
  RSpec.describe API::V1::Endpoints::Trucks::Update do
  ```
- Drive every example through a single `subject(:do_request)` that issues the HTTP call. Do NOT define `def login` / `def me` / etc. helper methods.
- Vary inputs per context with `let` overrides (`let(:headers)`, `let(:params)`, `let(:truck_id)`, ...). The subject reads them, so each context reshapes the request by swapping a `let`, not by passing args.
- Default the override `let`s at the top level to the happy-path value, then override in contexts. Default `let(:headers) { {} }` so the "without a token" path falls out for free.
- Call `do_request` from a `before` block before asserting on `response`. The first example in a tight test that only does one assertion may call `do_request` directly.

Skeleton:

```ruby
# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Trucks::Update do
  subject(:do_request) do
    patch "/api/v1/trucks/#{truck_id}", params: params, headers: headers
  end

  let(:headers)      { {} }
  let(:params)       { {make: "Scania"} }
  let(:admin_setup)  { auth_setup(role: :super_admin) }
  let(:admin_token)  { admin_setup[1] }
  let(:viewer_setup) { auth_setup(role: :driver_readonly) }
  let(:viewer_token) { viewer_setup[1] }
  let(:truck) do
    Truck.create!(plate_number: "AB-#{SecureRandom.hex(3)}", make: "Volvo", model: "FH", year: 2020)
  end
  let(:truck_id) { truck.id }

  context "without a token" do
    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when the user is not an admin" do
    let(:headers) { bearer_headers(viewer_token) }

    before { do_request }

    it "returns 403" do
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when the user is an admin" do
    let(:headers) { bearer_headers(admin_token) }

    context "with a kept truck" do
      before { do_request }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the truck" do
        expect(truck.reload.make).to eq("Scania")
      end
    end

    context "with a discarded truck" do
      before do
        truck.discard
        do_request
      end

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the 'Truck not found.' message" do
        expect(response.parsed_body.dig("error", "message")).to eq("Truck not found.")
      end
    end
  end
end
```

## Auth helpers

`spec/support/api_auth.rb` is included in every request spec. Use it instead of hand-rolling users and tokens.

```ruby
let(:admin_setup)  { auth_setup(role: :super_admin) }       # [user, token, app]
let(:admin)        { admin_setup[0] }
let(:admin_token)  { admin_setup[1] }
let(:viewer_setup) { auth_setup(role: :driver_readonly) }
let(:viewer_token) { viewer_setup[1] }

let(:headers) { bearer_headers(admin_token) }                # {"Authorization" => "Bearer <token>"}
```

When a service stamps `Current.user` (e.g. discard cascades stamping `discarded_by_id`), set it explicitly in the `before` block — the controller-level `authenticate!` won't fire in time for the assertion if your `before` does its own work first:

```ruby
before do
  Current.user = admin
  do_request
end
```

## Required coverage per endpoint

Every endpoint spec must exercise both happy and unhappy paths. Use the matrix below as a baseline and add resource-specific cases on top.

| Endpoint kind   | Happy path             | Required unhappy paths                                              |
| --------------- | ---------------------- | ------------------------------------------------------------------- |
| `list.rb`       | 200, includes kept records | 401 without token; discarded records excluded                   |
| `get.rb`        | 200, body has expected fields | 401 without token; 404 + `"<Model> not found."` for discarded; 404 + `"<Model> not found."` for missing id |
| `create.rb`     | 201, `Truck.count` changes by 1, body has client-supplied fields, `created_by_id` stamped to current user | 401 without token; 403 + `code: "forbidden"` for non-admin; 422 + `code: "validation_failed"` for missing required params; 422 for duplicate uniqueness; 422 for out-of-range or invalid values |
| `update.rb`     | 200, attribute persisted, body has updated value | 401 without token; 403 for non-admin; 404 for discarded; 404 for missing id; 422 for invalid values |
| `delete.rb`     | 200, body has `success: true` and `message: "<Model> <id> has been successfully discarded."`, record discarded, `discarded_by_id` stamped | 401 without token; 403 + `code: "forbidden"` for non-admin; 404 for discarded; 404 for missing id |

`delete` returns 200 with a `ServiceResult`/`DeleteResult` body — **not** 204. Assert the message string explicitly because clients render it.

### Asserting error shapes

The API wraps errors as `{error: {code:, message:, details?:}}`. Use `parsed_body.dig("error", "code")` / `("error", "message")` rather than matching status alone — clients branch on the code string.

```ruby
expect(response).to have_http_status(:forbidden)
expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
```

### Asserting validation failures

`Grape::Exceptions::ValidationErrors` (missing required params, wrong type) and `ActiveRecord::RecordInvalid` (uniqueness, numericality, etc.) both surface as 422 with `code: "validation_failed"`. Assert the code, not the human message.

## Entity specs

- `RSpec.describe` the entity constant.
- Build a real subject (a `User`, a `Doorkeeper::AccessToken`, a `Trucks::Discard::Result`, ...) and render it with `described_class.represent(obj).as_json`. Do NOT stub the source object.
- Assert on the rendered payload keys/values directly.
- For entities that format dates with `:iso_8601_date`, assert the rendered value is `YYYY-MM-DD` (not the full ISO 8601 datetime).

Skeleton:

```ruby
# frozen_string_literal: true

RSpec.describe API::V1::Entities::DeleteResult do
  let(:result)  { Trucks::Discard::Result.new(success: true, message: "Done.") }
  let(:payload) { described_class.represent(result).as_json }

  it "exposes success" do
    expect(payload[:success]).to be true
  end

  it "exposes the message" do
    expect(payload[:message]).to eq("Done.")
  end
end
```

For entities that re-use the project formatters in `app/api/api/v1/entities/base.rb`:

- `:iso_8601` renders full datetime (`"2026-05-01T13:24:01Z"`).
- `:iso_8601_date` renders date-only (`"2026-05-01"`). Do not name a custom formatter `:date` — it collides with a Grape::Entity instance method and breaks serialization. If you add a new formatter, make sure the project still loads (rspec will fail fast at the request layer).

## Service specs

Services live under `app/services/` and have their own specs at `spec/services/`. When a service returns a `Result` struct (e.g. `Trucks::Discard::Result`), the service spec must cover:

```ruby
describe "the returned result" do
  let(:result) { described_class.call(truck) }

  it "is a Trucks::Discard::Result" do
    expect(result).to be_a(Trucks::Discard::Result)
  end

  it "is successful" do
    expect(result.success).to be true
  end

  it "carries a message that names the truck id" do
    expect(result.message).to eq("Truck #{truck.id} has been successfully discarded.")
  end
end
```

The endpoint spec asserts the rendered body (`response.parsed_body["message"]`); the service spec asserts the Result struct directly. Both layers carry their own coverage — don't skip either.

## Verifying

After adding or editing a spec:

1. Run the focused spec file: `make rspec spec/api/v1/endpoints/<resource>/<action>_spec.rb`.
2. Run the full suite before considering the change done: `make rspec`.

The suite must stay green. If a spec is reaching for `Current.user` or hitting `Doorkeeper`, prefer `auth_setup` / `bearer_headers` over hand-rolled wiring.
