# frozen_string_literal: true

module API::V1::Endpoints::MaintenanceKinds
  class List < Grape::API
    resource :maintenance_kinds do
      desc "List maintenance kinds."
      get do
        authorize!(::MaintenanceKind, :index)
        present ::MaintenanceKind.kept.order(:name), with: ::API::V1::Entities::MaintenanceKind
      end
    end
  end
end
