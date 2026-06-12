# frozen_string_literal: true

module API::V1::Endpoints::Documents
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Documents::List
    mount API::V1::Endpoints::Documents::Create
    mount API::V1::Endpoints::Documents::Get
    mount API::V1::Endpoints::Documents::Update
    mount API::V1::Endpoints::Documents::Delete
  end
end
