# frozen_string_literal: true

module API::V1::Entities
  class Base < Grape::Entity
    format_with(:iso_8601) { |value| value&.iso8601 }
  end
end
