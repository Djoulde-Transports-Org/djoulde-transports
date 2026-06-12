# frozen_string_literal: true

module API::V1::Endpoints::Maintenances
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Maintenances::List
    mount API::V1::Endpoints::Maintenances::Create
    mount API::V1::Endpoints::Maintenances::Get
    mount API::V1::Endpoints::Maintenances::Update
    mount API::V1::Endpoints::Maintenances::Delete
  end
end
