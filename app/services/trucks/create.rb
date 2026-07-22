# frozen_string_literal: true

# A truck (head) and its tank are registered as a unit: the schema pairs them
# 1:1 (`tanks.truck_id` is NOT NULL + UNIQUE), so we build both in one
# transaction. An invalid tank rolls back the truck, leaving no orphan head.
module Trucks
  class Create < ApplicationService
    DOC_TYPE_BY_PARAM = {
      truck_insurance_expires_on:      :truck_insurance,
      cargo_insurance_expires_on:      :product_insurance,
      technical_inspection_expires_on: :technical_inspection,
      operating_permit_expires_on:     :transport_card,
      truck_registration_expires_on:   :truck_registration,
    }.freeze

    DOC_TITLE_BY_TYPE = {
      truck_insurance:      "Assurance camion",
      product_insurance:    "Assurance produit",
      technical_inspection: "Visite technique",
      transport_card:       "Carte de transport",
      truck_registration:   "Carte grise",
    }.freeze

    def initialize(truck_attrs:, tank_attrs:, created_by:, last_oil_change_on: nil, document_expiries: {})
      @truck_attrs        = truck_attrs
      @tank_attrs         = tank_attrs
      @created_by         = created_by
      @last_oil_change_on = last_oil_change_on
      @document_expiries  = document_expiries || {}
    end

    def call
      ApplicationRecord.transaction do
        truck = ::Truck.new(@truck_attrs)
        truck.created_by = @created_by
        truck.save!
        truck.create_tank!(@tank_attrs)
        create_last_oil_change!(truck)
        create_documents!(truck)
        truck
      end
    end

    private

    attr_reader :truck_attrs, :tank_attrs, :created_by, :last_oil_change_on, :document_expiries

    def create_last_oil_change!(truck)
      return if last_oil_change_on.blank?

      truck.maintenances.create!(kind: :oil_change, state: :completed, performed_on: last_oil_change_on)
    end

    def create_documents!(truck)
      document_expiries.each do |param, expires_on|
        next if expires_on.blank?

        doc_type = DOC_TYPE_BY_PARAM.fetch(param.to_sym)
        truck.documents.create!(
          doc_type:   doc_type,
          expires_on: expires_on,
          title:      DOC_TITLE_BY_TYPE.fetch(doc_type),
          number:     "#{truck.plate_number}-#{doc_type}"
        )
      end
    end
  end
end
