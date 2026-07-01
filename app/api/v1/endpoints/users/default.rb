# frozen_string_literal: true

module API::V1::Endpoints::Users
  class Default < Grape::API
    mount API::V1::Endpoints::Users::Create
    mount API::V1::Endpoints::Users::Delete
    mount API::V1::Endpoints::Users::Me
  end
end
