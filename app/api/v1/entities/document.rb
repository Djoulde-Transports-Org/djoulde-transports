# frozen_string_literal: true

module API::V1::Entities
  class Document < Base
    expose :id,                documentation: {type: "Integer", desc: "The ID of the document."}
    expose :documentable_type, documentation: {type: "String", desc: "The type of the document's owner."}
    expose :documentable_id,   documentation: {type: "Integer", desc: "The id of the document's owner."}
    expose :doc_type,          documentation: {type: "String", desc: "The kind of document."}
    expose :number,            documentation: {type: "String", desc: "The document number."}
    expose :title,             documentation: {type: "String", desc: "The title of the document."}
    expose :issued_on,         format_with: :iso_8601_date, documentation: {type: "Date", desc: "The date the document was issued."}
    expose :expires_on,        format_with: :iso_8601_date, documentation: {type: "Date", desc: "The date the document expires."}
    expose :uploaded_by_id,    documentation: {type: "Integer", desc: "The ID of the user who uploaded the document."}
    expose :created_at,        format_with: :iso_8601, documentation: {type: "DateTime", desc: "The date the document was uploaded."}
    expose :uploaded_by, documentation: {type: "Object", desc: "The user who uploaded the document (id, name), if any."} do |document, _opts|
      uploaded_by_payload(document)
    end
    expose :documentable_label,
           documentation: {type: "String", desc: "A human-readable label for the linked entity (name, plate number, delivery note number, etc.), if resolvable."} do |document, _opts|
      documentable_label(document)
    end
    expose :documentable_date,
           documentation: {type: "Date", desc: "The date associated with the linked entity, if any (currently only set for billing statements, as the covered month)."} do |document, _opts|
      document.documentable_type == "BillingStatement" ? document.documentable&.month&.iso8601 : nil
    end
    expose :file_attached, documentation: {type: "Boolean", desc: "Whether a file is attached to the document."} do |document|
      document.file.attached?
    end
    expose :file_size, documentation: {type: "Integer", desc: "The file size in bytes, or null if no file is attached."} do |document|
      document.file.attached? ? document.file.byte_size : nil
    end

    protected

    def uploaded_by_payload(document)
      user = document.uploaded_by
      return nil unless user

      {id: user.id, name: user.employee&.full_name || user.email}
    end

    def documentable_label(document)
      case document.documentable_type
      when "Employee"      then document.documentable&.full_name
      when "Truck", "Tank" then document.documentable&.plate_number
      when "Maintenance"   then maintenance_truck_plate(document)
      when "Trip"          then trip_delivery_note_number(document)
      end
    end

    # Uses the batched lookup the list endpoint precomputes for the whole page
    # when present; falls back to a live (single-record) association lookup
    # otherwise, e.g. when representing one document after create/update.
    def maintenance_truck_plate(document)
      lookup = options[:truck_plates_by_maintenance_id]
      return lookup[document.documentable_id] if lookup

      document.documentable&.truck&.plate_number
    end

    def trip_delivery_note_number(document)
      lookup = options[:delivery_notes_by_trip_id]
      return lookup[document.documentable_id] if lookup

      document.documentable&.delivery_note&.number
    end
  end
end
