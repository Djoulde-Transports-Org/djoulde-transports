# frozen_string_literal: true

module API::V1::Endpoints::Routes
  module Common
    extend Grape::API::Helpers

    # Named `route_record` (not `route`) to avoid shadowing Grape's built-in
    # `route` endpoint helper, which returns the current route info.
    def route_record
      @route_record ||= find_kept!(::Route)
    end

    def route_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
