# frozen_string_literal: true

module API::V1::Entities
  class DeleteResult < Base
    expose :success, documentation: {desc: "Whether the operation was successful."}
    expose :message, documentation: {desc: "A message describing the result."}
  end
end
