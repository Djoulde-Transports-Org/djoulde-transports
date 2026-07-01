# frozen_string_literal: true

module API::V1
  class Base < Grape::API
    version "v1", using: :path
    format :json
    content_type :json, "application/json"

    helpers API::V1::Helpers::Errors
    helpers API::V1::Helpers::Auth
    helpers API::V1::Helpers::Policy

    rescue_from Pundit::NotAuthorizedError do |error|
      error!({error: {code: "forbidden", message: "You are not allowed to perform this action."}}, 403)
    end

    rescue_from ActiveRecord::RecordNotFound do |error|
      error!({error: {code: "not_found", message: "Resource not found."}}, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      error!({error: {code: "validation_failed",
                       message: "Validation failed.",
                       details: error.record.errors.as_json}}, 422)
    end

    rescue_from ActiveRecord::RecordNotUnique do |error|
      error!({error: {code: "conflict", message: "Resource already exists."}}, 409)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |error|
      error!({error: {code: "validation_failed",
                       message: "Validation failed.",
                       details: error.full_messages}}, 422)
    end

    rescue_from ArgumentError do |error|
      error!({error: {code: "invalid_argument", message: error.message}}, 422)
    end

    unless Rails.env.local?
      rescue_from :all do |error|
        Rails.logger.error("[API] #{error.class}: #{error.message}")
        error!({error: {code: "internal_server_error", message: "Something went wrong."}}, 500)
      end
    end

    mount API::V1::Endpoints::Users::Default

    mount API::V1::Endpoints::Trucks::Default
    mount API::V1::Endpoints::Tanks::Default
    mount API::V1::Endpoints::Routes::Default
    mount API::V1::Endpoints::Trips::Default
    mount API::V1::Endpoints::Maintenances::Default
    mount API::V1::Endpoints::Documents::Default
    mount API::V1::Endpoints::BillingStatements::Default
    mount API::V1::Endpoints::BillingLineItems::Default
  end
end
