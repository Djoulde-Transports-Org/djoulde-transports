# frozen_string_literal: true

module API::V1::Entities
  class Tank < Base
    expose :id, documentation: {type: "Integer", desc: "The ID of the tank."}
    expose :truck_id, documentation: {type: "Integer", desc: "The ID of the truck (head) the tank is attached to."}
    expose :plate_number, documentation: {type: "String", desc: "The plate number of the tank."}
    expose :vin, documentation: {type: "String", desc: "The VIN of the tank."}
    expose :make, documentation: {type: "String", desc: "The make of the tank."}
    expose :model, documentation: {type: "String", desc: "The model of the tank."}
    expose :year, documentation: {type: "Integer", desc: "The year of the tank."}
    expose :capacity, documentation: {type: "Integer", desc: "The capacity of the tank in liters."}
    expose :status, documentation: {type: "String", desc: "The status of the tank."}

    expose :conformity_certificate_expires_on, format_with: :iso_8601_date,
           documentation: {type: "String", desc: "Conformity certificate (certificat de baremage) expiry date."} do |_, _|
      conformity_certificate_expires_on
    end
    expose :conformity_certificate_days_remaining,
           documentation: {type: "Integer", desc: "Days until the conformity certificate expires (negative if expired)."} do |_, _|
      days_remaining(conformity_certificate_expires_on)
    end

    private

    def conformity_certificate_expires_on
      kept_expiry_for(object.documents, :conformity_certificate?, :expires_on)
    end
  end
end
