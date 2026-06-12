# frozen_string_literal: true

module API::V1::Entities
  class User < Base
    expose :id, documentation: {type: "Integer", desc: "The user ID"}
    expose :email, documentation: {type: "String", desc: "The email address"}
    expose :roles, documentation: {type: "Array", desc: "The user roles"} do |user, _opts|
      user.roles.map(&:name)
    end
  end
end
