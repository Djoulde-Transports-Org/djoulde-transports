# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Routes::List
    mount API::V1::Endpoints::Routes::Create
    mount API::V1::Endpoints::Routes::Get
    mount API::V1::Endpoints::Routes::Update
    mount API::V1::Endpoints::Routes::Delete
  end
end
