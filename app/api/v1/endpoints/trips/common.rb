# frozen_string_literal: true

module API::V1::Endpoints::Trips
  module Common
    extend Grape::API::Helpers

    def trip
      @trip ||= find_kept!(::Trip)
    end

    def trip_params
      declared(params, include_missing: false).except(:id, :delivery_note, :missing_quantity)
    end

    def delivery_note_params
      declared(params, include_missing: false)[:delivery_note]
    end

    def missing_quantity_param
      declared(params, include_missing: false)[:missing_quantity]
    end
  end
end
