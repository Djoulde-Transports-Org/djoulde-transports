# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  module Common
    extend Grape::API::Helpers

    def maintenance
      @maintenance ||= find_kept!(::Maintenance)
    end

    def maintenance_params
      declared(params, include_missing: false).except(:id, :parts)
    end

    def parts_params
      declared(params, include_missing: false)[:parts]
    end
  end
end
