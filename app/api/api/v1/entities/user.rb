# frozen_string_literal: true

module API::V1::Entities
  class User < Base
    expose :id, documentation: {type: "integer", desc: "The user ID"}
    expose :email, documentation: {type: "string", desc: "The email address"}
    expose :roles, documentation: {type: "array", desc: "The user roles"} do |user, _opts|
      user.roles.map(&:name)
    end
  end
end
