# frozen_string_literal: true

module API::V1::Entities
  class Base < Grape::Entity
    format_with(:iso_8601)      { |value| value&.iso8601 }
    format_with(:iso_8601_date) { |value| value&.to_date&.iso8601 }
  end
end
