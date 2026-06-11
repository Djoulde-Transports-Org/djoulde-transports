# frozen_string_literal: true

module API::V1::Entities
  class Session < Base
    expose :access_token, documentation: {type: "String", desc: "The access token"} do |token, _opts|
      token.token
    end
    expose :token_type, documentation: {type: "String", desc: "The token type"} do |_token, _opts|
      "Bearer"
    end
    expose :expires_in, documentation: {type: "Integer", desc: "The expiration time in seconds"}
    expose :created_at, documentation: {type: "Integer", desc: "The creation time in seconds"} do |token, _opts|
      token.created_at.to_i
    end
    expose :user_id, documentation: {type: "Integer", desc: "The user ID"} do |token, _opts|
      token.resource_owner_id
    end
  end
end
