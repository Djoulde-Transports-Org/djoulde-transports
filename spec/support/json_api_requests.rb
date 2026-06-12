# frozen_string_literal: true

# Default request specs under spec/api to JSON: serializes params to JSON
# and sets `Content-Type: application/json`. Pass `as: <other>` to override.
module JsonApiRequests
  %i(get post put patch delete).each do |verb|
    define_method(verb) do |path, **kwargs|
      kwargs[:as] ||= :json
      super(path, **kwargs)
    end
  end
end

RSpec.configure do |config|
  config.include JsonApiRequests, type: :request, file_path: %r(spec/api/)
end
