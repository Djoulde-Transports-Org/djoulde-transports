# frozen_string_literal: true

module API::V1::Entities
  class Truck < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the truck."}
    expose :plate_number, documentation: {type: "String", desc: "The plate number of the truck."}
    expose :vin, documentation: {type: "String", desc: "The VIN of the truck."}
    expose :make, documentation: {type: "String", desc: "The make of the truck."}
    expose :model, documentation: {type: "String", desc: "The model of the truck."}
    expose :year, documentation: {type: "Integer", desc: "The year of the truck."}
    expose :status, documentation: {type: "String", desc: "The status of the truck."}
    expose :created_by_id, documentation: {type: "Integer", desc: "The ID of the user who created the truck."}
    expose :tank,   using: ::API::V1::Entities::Tank,     documentation: {type: "Object", desc: "The tank attached to the truck."}
    expose :driver, using: ::API::V1::Entities::Employee, documentation: {type: "Object", desc: "The driver (Employee) assigned to the truck."}

    expose :last_oil_change_on, format_with: :iso_8601_date,
           documentation: {type: "String", desc: "Date of the most recent oil change maintenance."} do |_, _|
      last_oil_change_on
    end

    expose :truck_insurance_expires_on, format_with: :iso_8601_date,
           documentation: {type: "String", desc: "Truck insurance (assurance camion) expiry date."} do |_, _|
      truck_insurance_expires_on
    end
    expose :truck_insurance_days_remaining,
           documentation: {type: "Integer", desc: "Days until truck insurance expires (negative if expired)."} do |_, _|
      days_remaining(truck_insurance_expires_on)
    end

    expose :cargo_insurance_expires_on, format_with: :iso_8601_date,
           documentation: {type: "String", desc: "Cargo insurance (assurance produit) expiry date."} do |_, _|
      cargo_insurance_expires_on
    end
    expose :cargo_insurance_days_remaining,
           documentation: {type: "Integer", desc: "Days until cargo insurance expires (negative if expired)."} do |_, _|
      days_remaining(cargo_insurance_expires_on)
    end

    expose :technical_inspection_expires_on, format_with: :iso_8601_date,
           documentation: {type: "String", desc: "Technical inspection (visite technique) expiry date."} do |_, _|
      technical_inspection_expires_on
    end
    expose :technical_inspection_days_remaining,
           documentation: {type: "Integer", desc: "Days until technical inspection expires (negative if expired)."} do |_, _|
      days_remaining(technical_inspection_expires_on)
    end

    expose :operating_permit_expires_on, format_with: :iso_8601_date,
           documentation: {type: "String", desc: "Operating permit (permis de circulation) expiry date."} do |_, _|
      operating_permit_expires_on
    end
    expose :operating_permit_days_remaining,
           documentation: {type: "Integer", desc: "Days until operating permit expires (negative if expired)."} do |_, _|
      days_remaining(operating_permit_expires_on)
    end

    expose :trips_count,
           documentation: {type: "Integer", desc: "Total number of kept trips for this truck."} do |_, _|
      trips_count
    end
    expose :total_km,
           documentation: {type: "Decimal", desc: "Total distance driven across all kept trips."} do |_, _|
      total_km
    end
    expose :total_liters_delivered,
           documentation: {type: "Integer", desc: "Total liters delivered across all kept delivery notes."} do |_, _|
      total_liters_delivered
    end

    private

    def last_oil_change_on
      kept_expiry_for(object.maintenances, :oil_change?, :performed_on)
    end

    def truck_insurance_expires_on
      kept_expiry_for(object.documents, :insurance?, :expires_on)
    end

    def cargo_insurance_expires_on
      kept_expiry_for(object.documents, :registration?, :expires_on)
    end

    def technical_inspection_expires_on
      kept_expiry_for(object.documents, :inspection?, :expires_on)
    end

    def operating_permit_expires_on
      kept_expiry_for(object.documents, :license?, :expires_on)
    end

    def trips_count
      object.trips.kept.count
    end

    def total_km
      object.trips.kept.sum(:distance_km).to_f
    end

    def total_liters_delivered
      ::DeliveryNote.kept.joins(:trip).where(trips: {truck_id: object.id}).sum("diesel_quantity + gasoline_quantity")
    end

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
