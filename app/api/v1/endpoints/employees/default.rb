# frozen_string_literal: true

module API::V1::Endpoints::Employees
  class Default < Grape::API
    before { authenticate! }

    mount API::V1::Endpoints::Employees::List
    mount API::V1::Endpoints::Employees::Get
    mount API::V1::Endpoints::Employees::Create
    mount API::V1::Endpoints::Employees::Update
    mount API::V1::Endpoints::Employees::Delete
  end
end
