# frozen_string_literal: true

module API::V1::Endpoints::Trips
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Trips::List
    mount API::V1::Endpoints::Trips::Create
    mount API::V1::Endpoints::Trips::Get
    mount API::V1::Endpoints::Trips::Update
    mount API::V1::Endpoints::Trips::Delete
  end
end
