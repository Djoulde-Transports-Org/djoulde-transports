# frozen_string_literal: true

module API::V1::Endpoints::Users
  class Default < Grape::API
    mount API::V1::Endpoints::Users::Session::Create
    mount API::V1::Endpoints::Users::Session::Delete
    mount API::V1::Endpoints::Users::Me
  end
end
