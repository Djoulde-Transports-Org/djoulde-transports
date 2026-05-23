---
name: api-spec-pattern
description: Use when writing or editing any RSpec spec under spec/api/ (Grape endpoints and entities). Enforces the project's request- and entity-spec conventions so new specs match the existing pattern without boilerplate.
---

# API spec pattern

All specs that touch the Grape API live under `spec/api/` and follow the rules below. The harness wiring is already in place (see `.rspec`, `spec/rails_helper.rb`, `spec/support/json_api_requests.rb`); the rules exist so you don't fight it.

## Locations

Mirror the source tree under `app/api/api/v1/`:

| Source                                              | Spec                                                   |
| --------------------------------------------------- | ------------------------------------------------------ |
| `app/api/api/v1/endpoints/<resource>/<name>.rb`     | `spec/api/v1/endpoints/<resource>/<name>_spec.rb`      |
| `app/api/api/v1/entities/<name>.rb`                 | `spec/api/v1/entities/<name>_spec.rb`                  |

Do not put API specs under `spec/requests/`. Reserve `spec/requests/` for non-API request specs (e.g. `health_spec.rb`, `rack_attack_spec.rb`).

## What the harness gives you for free

You do NOT need to add any of these to a spec:

- `require "rails_helper"` — `.rspec` already loads it.
- `type: :request` — `spec/rails_helper.rb` derives it from the `spec/api/` path.
- `Content-Type: application/json` / `.to_json` — `spec/support/json_api_requests.rb` defaults every `get/post/put/patch/delete` under `spec/api/` to `as: :json`, which serializes params and sets the header.

If you find yourself adding any of the above to a new spec, delete it.

## Endpoint specs

- `RSpec.describe` the endpoint constant directly, not a route string:
  ```ruby
  RSpec.describe API::V1::Endpoints::Users::Sessions do
  ```
- Drive every example through a single `subject(:do_request)` that issues the HTTP call. Do not define `def login` / `def me` / etc. helper methods.
- Vary inputs per context with `let` overrides (`let(:headers)`, `let(:email)`, `let(:password_param)`, ...). The subject reads them so each context reshapes the request by swapping a `let`, not by passing args.
- Default the override `let`s at the top level to the happy-path value, then override in contexts.
- Call `do_request` from a `before` block (or directly in the example) before asserting on `response`.

Skeleton:

```ruby
# frozen_string_literal: true

RSpec.describe API::V1::Endpoints::Users::Sessions do
  subject(:do_request) do
    post "/api/v1/sessions", params: {email: email, password: password_param}
  end

  let(:password)       { "correct horse battery staple" }
  let(:user)           { User.create!(email: "u@example.com", password: password) }
  let(:email)          { user.email }
  let(:password_param) { password }

  context "with invalid credentials" do
    let(:password_param) { "wrong" }

    before { do_request }

    it "returns 401" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
```

For authenticated endpoints, pass the token via `let(:headers)`:

```ruby
subject(:do_request) { get "/api/v1/me", headers: headers }

let(:headers) { {} } # default: unauthenticated

context "with a valid token" do
  let(:headers) { {"Authorization" => "Bearer #{token.token}"} }
  # ...
end
```

## Entity specs

- `RSpec.describe` the entity constant.
- Build a real subject (a `User`, a `Doorkeeper::AccessToken`, ...) and render it with `described_class.represent(obj).as_json`. Don't stub the source object.
- Assert on the rendered payload keys/values directly.

Skeleton:

```ruby
# frozen_string_literal: true

RSpec.describe API::V1::Entities::Session do
  let(:user)    { User.create!(email: "entity@example.com", password: "correct horse battery staple") }
  let(:app)     { OauthApplication.create!(name: "spa", redirect_uri: "https://example.com/cb", owner: user) }
  let(:token)   { Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: user.id, scopes: "default") }
  let(:payload) { described_class.represent(token).as_json }

  it "exposes the token string as access_token" do
    expect(payload[:access_token]).to eq(token.token)
  end
end
```

## Verifying

After adding or editing a spec, run `make rspec spec/api/<path>` (and `make rspec` before considering the change done). The suite must stay green.
