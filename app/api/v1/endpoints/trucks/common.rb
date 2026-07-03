# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  module Common
    extend Grape::API::Helpers

    def truck
      @truck ||= begin
        record = policy_scope(::Truck).kept
                   .includes(:tank, :maintenances, :documents, :driver)
                   .find_by(id: params[:id])
        not_found!(message: "Truck not found.") unless record
        record
      end
    end

    def truck_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
