# frozen_string_literal: true

module API::V1::Endpoints::Trips
  module Common
    extend Grape::API::Helpers

    def trip
      @trip ||= find_kept!(::Trip)
    end

    def trip_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
