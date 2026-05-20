module API::V1
  class Base < Grape::API
    version "v1", using: :path
    format :json
    content_type :json, "application/json"

    helpers API::V1::Helpers::Auth

    mount API::V1::Sessions
    mount API::V1::Me
  end
end
