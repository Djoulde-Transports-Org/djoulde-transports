# frozen_string_literal: true

module API::V1::Endpoints::Trips
  module Common
    extend Grape::API::Helpers

    def trip
      @trip ||= begin
        record = policy_scope(::Trip).kept
                   .includes(:route, :delivery_note, :driver, billing_line_items: :billing_statement,
                             truck: [ :maintenances, :documents, :tank, :driver ])
                   .find_by(id: params[:id])
        not_found!(message: "Trip not found.") unless record
        record
      end
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
