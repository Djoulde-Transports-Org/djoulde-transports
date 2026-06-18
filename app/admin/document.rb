# frozen_string_literal: true

ActiveAdmin.register Document do
  menu parent: "Operations", priority: 4

  AdminResources::Discardable.install(self)

  # documentable is polymorphic; these are the models that `has_many :documents`.
  DOCUMENTABLE_TYPES = %w(Truck Tank Trip Maintenance BillingStatement).freeze

  permit_params :documentable_type, :documentable_id, :doc_type, :number, :title,
    :issued_on, :expires_on, :uploaded_by_id, :file

  filter :number
  filter :title
  filter :doc_type, as: :select, collection: Document.doc_types.keys
  filter :documentable_type, as: :select, collection: DOCUMENTABLE_TYPES

  index do
    selectable_column
    id_column
    column :number
    column :title
    column :doc_type
    column("Attached to") { |doc| "#{doc.documentable_type} ##{doc.documentable_id}" }
    column :expires_on
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :number
      row :title
      row :doc_type
      row("Attached to") { |doc| "#{doc.documentable_type} ##{doc.documentable_id}" }
      row :issued_on
      row :expires_on
      row("File") { |doc| doc.file.attached? ? link_to(doc.file.filename, url_for(doc.file)) : status_tag("none") }
      row("Uploaded by") { |doc| doc.uploaded_by&.email }
      row :created_at
      row :discarded_at
      row("Discarded by") { |doc| doc.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :documentable_type, as: :select, collection: DOCUMENTABLE_TYPES
      f.input :documentable_id
      f.input :doc_type, as: :select, collection: Document.doc_types.keys
      f.input :number
      f.input :title
      f.input :issued_on, as: :string, input_html: {type: "date"}
      f.input :expires_on, as: :string, input_html: {type: "date"}
      f.input :file, as: :file
    end
    f.actions
  end

  controller do
    def build_resource
      super.tap { |doc| doc.uploaded_by ||= current_admin }
    end
  end
end
