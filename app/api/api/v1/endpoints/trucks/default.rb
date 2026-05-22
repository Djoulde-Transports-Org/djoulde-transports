# frozen_string_literal: true

module API::V1::Endpoints::Trucks
  class Default < Grape::API
    mount API::V1::Endpoints::Trucks::List
    mount API::V1::Endpoints::Trucks::Create
    mount API::V1::Endpoints::Trucks::Get
    mount API::V1::Endpoints::Trucks::Update
    mount API::V1::Endpoints::Trucks::Delete
  end
end
