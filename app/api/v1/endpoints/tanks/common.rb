# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  module Common
    extend Grape::API::Helpers

    def tank
      @tank ||= find_kept!(::Tank)
    end

    def tank_params
      declared(params, include_missing: false).except(:id)
    end
  end
end
