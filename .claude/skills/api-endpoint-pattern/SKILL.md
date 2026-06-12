---
name: api-endpoint-pattern
description: Use when writing or editing any Grape endpoint under app/api/v1/endpoints/ or any entity under app/api/v1/entities/. Enforces the project's resource-module layout (one action per file), shared Common helpers, entity formatters, and service Result conventions so new resources match the existing pattern without boilerplate.
---

# API endpoint and entity pattern

Every API resource follows the same shape. Match this layout when adding a new resource (`trucks`, `trips`, `maintenances`, ...).

## Endpoint layout

One **action per file**, all wired together by a `Default` mount. Mirror this tree:

```
app/api/v1/endpoints/<resource>/
  common.rb     # shared finders + params helpers (NOT mounted)
  default.rb    # mounts the actions, applies before-filters
  list.rb       # GET    /<resource>
  create.rb     # POST   /<resource>
  get.rb        # GET    /<resource>/:id
  update.rb     # PATCH  /<resource>/:id
  delete.rb     # DELETE /<resource>/:id
```

`Default` mounts each action and is the single thing mounted from `API::V1::Base`. Apply `before { authenticate! }` here so every nested action inherits it; individual action files do NOT repeat the filter.

```ruby
# app/api/v1/endpoints/trucks/default.rb
module API::V1::Endpoints::Trucks
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Trucks::List
    mount API::V1::Endpoints::Trucks::Create
    mount API::V1::Endpoints::Trucks::Get
    mount API::V1::Endpoints::Trucks::Update
    mount API::V1::Endpoints::Trucks::Delete
  end
end
```

## Common module

Shared helpers live in a `Common` module per resource. Endpoints that need `find_kept!` or `<resource>_params` pull it in with `helpers`, **not** `include`. Grape's helpers run in the endpoint scope; `include` adds methods to the API class and they won't be visible inside action blocks.

```ruby
# app/api/v1/endpoints/trucks/common.rb
module API::V1::Endpoints::Trucks
  module Common
    extend Grape::API::Helpers

    def truck
      @truck ||= find_kept!(::Truck)
    end

    def truck_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
```

`.except(:id)` is mandatory: any action that lives under `route_param :id, type: Integer` puts `:id` into `declared(params)`, and `update!`/`new` should never receive a primary-key value from the client.

Wire it into every action that needs it:

```ruby
class Update < Grape::API
  helpers API::V1::Endpoints::Trucks::Common   # NOT `include`
  ...
end
```

## Action shape

- Member routes (`get`/`update`/`delete`) live inside `route_param :id, type: Integer do ... end`. Don't use `get "/:id"` — you lose integer coercion and the shared scope.
- Every action runs `authorize!(record, :action)` before mutating.
- Use `present <record>, with: API::V1::Entities::<Foo>` for serialization. Don't hand-roll JSON.
- Add `desc` and a `params do` block on every action. Inside `params`, attach `documentation: {desc: "..."}` to each declared param.
- Mutating helpers (`create_truck!`, `update_truck!`) live in `helpers do ... end` inside the action's class, not in `Common`, so the read shape stays separate from the write shape.

```ruby
class Create < Grape::API
  helpers API::V1::Endpoints::Trucks::Common

  helpers do
    def create_truck!
      truck = ::Truck.new(truck_params)
      truck.created_by = current_user           # server-stamped, never trust the client
      truck.save!
      truck
    end
  end

  resource :trucks do
    desc "Create a truck."
    params do
      requires :plate_number, type: String, documentation: {desc: "The plate number of the truck."}
      # ...
    end
    post do
      authorize!(::Truck, :create)
      present create_truck!, with: ::API::V1::Entities::Truck
    end
  end
end
```

## Errors

`API::V1::Base` already registers `rescue_from` blocks for `Pundit::NotAuthorizedError`, `ActiveRecord::RecordNotFound`, `ActiveRecord::RecordInvalid`, `ActiveRecord::RecordNotUnique`, and `Grape::Exceptions::ValidationErrors`. Don't add per-endpoint rescues for these.

Custom 404s come from `find_kept!`, which formats the message as `"<ModelName> not found."` via `klass.model_name.human`. New resources get per-model messages for free.

## Entities

Entities live at `app/api/v1/entities/<name>.rb` and inherit from `API::V1::Entities::Base`. `Base` declares two formatters:

- `format_with: :iso_8601` for full timestamps (e.g. user-facing log lines).
- `format_with: :iso_8601_date` for date-only fields (`created_at`, `updated_at`, `discarded_at`, ...). Use this by default for record timestamps — clients want `2026-05-01`, not `2026-05-01T13:24:01Z`.

Every `expose` carries a `documentation: {type: "...", desc: "..."}` hash. Keep types capitalized (`"Integer"`, `"String"`, `"DateTime"`).

```ruby
module API::V1::Entities
  class Truck < Base
    expose :id,           documentation: {type: "Integer", desc: "The ID of the truck."}
    expose :plate_number, documentation: {type: "String",  desc: "The plate number of the truck."}
    expose :created_at,   format_with: :iso_8601_date, documentation: {type: "DateTime", desc: "The creation time."}
  end
end
```

Don't name a custom formatter `:date` — it collides with a method on Grape::Entity instances and breaks serialization at request time. Use `:iso_8601_date` (or another non-colliding name).

## Services + Result struct

Endpoints that perform multi-step mutations call into a service under `app/services/<resource>/<action>.rb` that inherits from `ApplicationService`. The class method `.call` is already provided.

Services that need to surface a user-facing message to the endpoint define a local `Result` struct and return an instance of it:

```ruby
module Trucks
  class Discard < ApplicationService
    Result = Struct.new(:success, :message)

    def initialize(truck)
      @truck = truck
    end

    def call
      ApplicationRecord.transaction do
        # cascade discards...
        @truck.discard!
      end
      Result.new(success: true, message: "Truck #{@truck.id} has been successfully discarded.")
    end
  end
end
```

The endpoint presents that Result through a generic entity (`DeleteResult` exposes `success` + `message`):

```ruby
delete do
  authorize!(truck, :destroy)
  result = ::Trucks::Discard.call(truck)
  present result, with: ::API::V1::Entities::DeleteResult
end
```

Return status code: `200` with the result body, **not** `204 No Content`. Clients want the success message; a body-less response gives them nothing to display.

## Specs

See the `api-spec-pattern` skill for spec conventions: one spec file per endpoint file, `RSpec.describe` the constant, `subject(:do_request)`, `let` overrides per context. Always cover both happy paths (200/201) and unhappy paths (401 without token, 403 from policy, 404 from `find_kept!`, 422 from validation).

## Verifying

After adding or editing an endpoint or entity, run `make rspec` (or `docker compose --profile skeleton exec dev bundle exec rspec`). The suite must stay green.
