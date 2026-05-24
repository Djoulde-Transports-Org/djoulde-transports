# frozen_string_literal: true

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
