# frozen_string_literal: true

module API::V1::Endpoints::MaintenanceKinds
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::MaintenanceKinds::List
  end
end
