# frozen_string_literal: true

module API::V1::Entities
  class DeleteResult < Base
    expose :success
    expose :message
  end
end
