class API < Grape::API
  format :json
  prefix "api"

  mount API::V1::Base
end
