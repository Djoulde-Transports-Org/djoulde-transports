# frozen_string_literal: true

module API::V1::Endpoints::Tanks
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Tanks::List
    mount API::V1::Endpoints::Tanks::Create
    mount API::V1::Endpoints::Tanks::Get
    mount API::V1::Endpoints::Tanks::Update
    mount API::V1::Endpoints::Tanks::Delete
  end
end
