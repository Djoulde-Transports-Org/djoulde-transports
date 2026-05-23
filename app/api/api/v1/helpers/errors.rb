# frozen_string_literal: true

module API::V1::Helpers
  # Renders JSON errors in the shape `{error: {code:, message:, details:}}`
  # so SvelteKit (ticket 13) can branch on `code` instead of HTTP status alone.
  module Errors
    extend Grape::API::Helpers

    def fail_with!(code:, message:, status:, details: nil)
      payload = {code: code, message: message}
      payload[:details] = details unless details.nil?
      error!({error: payload}, status)
    end

    def unauthorized!(code: "unauthorized", message: "Authentication required.")
      fail_with!(code: code, message: message, status: 401)
    end

    def forbidden!(code: "forbidden", message: "You are not allowed to perform this action.", details: nil)
      fail_with!(code: code, message: message, status: 403, details: details)
    end

    def not_found!(code: "not_found", message: "Resource not found.")
      fail_with!(code: code, message: message, status: 404)
    end

    def unprocessable!(details, code: "validation_failed", message: "Validation failed.")
      fail_with!(code: code, message: message, status: 422, details: details)
    end
  end
end
