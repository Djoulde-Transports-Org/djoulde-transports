# frozen_string_literal: true

module API::V1::Entities
  class Base < Grape::Entity
    format_with(:iso_8601)      { |value| value&.iso8601 }
    format_with(:iso_8601_date) { |value| value&.to_date&.iso8601 }

    protected

    def kept_expiry_for(association, type_predicate, date_field)
      association.to_a
        .select { |r| r.discarded_at.nil? && r.public_send(type_predicate) }
        .filter_map(&date_field)
        .max
    end

    def days_remaining(date)
      date ? (date - Date.current).to_i : nil
    end
  end
end
