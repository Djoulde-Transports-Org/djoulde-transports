# frozen_string_literal: true

# Ticket 12: OAuth applications. Each application is owned by exactly one User
# (a UNIQUE index on owner_type/owner_id enforces it), so when creating one the
# owner picker is limited to Users that do not already own a kept application.
# The model's uniqueness validation is the backstop that turns a racing index
# violation into a friendly error instead of a 500.
ActiveAdmin.register OauthApplication do
  menu parent: "OAuth", priority: 1

  AdminResources::Discardable.install(self)

  permit_params :name, :redirect_uri, :scopes, :confidential, :owner_id, :owner_type

  filter :name
  filter :owner_id, as: :select, collection: -> { User.order(:email).pluck(:email, :id) }, label: "Owner"
  filter :created_by_id, as: :select, collection: -> { User.order(:email).pluck(:email, :id) }, label: "Created by"
  filter :last_used_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column("Owner") { |app| app.owner&.email }
    column("Created by") { |app| app.created_by&.email }
    column :calls_count
    column :last_used_at
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row("Owner") { |app| app.owner&.email }
      row("Created by") { |app| app.created_by&.email }
      row :calls_count
      row :last_used_at
      row :scopes
      row :confidential
      row :redirect_uri
      row :uid
      row :created_at
      row :updated_at
      row :discarded_at
      row("Discarded by") { |app| app.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      # Limit the picker to Users that have no kept application yet, but keep
      # the record's current owner selectable when editing.
      taken = OauthApplication.kept.where.not(owner_id: nil).pluck(:owner_id)
      taken -= [ f.object.owner_id ] if f.object.persisted?
      f.input :owner_id, as: :select,
        collection: User.where.not(id: taken).order(:email).pluck(:email, :id),
        include_blank: "— none —", label: "Owner (User)"
      f.input :owner_type, as: :hidden, input_html: {value: "User"}
      f.input :name
      f.input :redirect_uri
      f.input :scopes
      f.input :confidential
    end
    f.actions
  end

  controller do
    # Stamp the creating admin. build_resource runs for both new and create, so
    # this also seeds the value before validation on a failed create.
    def build_resource
      super.tap { |app| app.created_by ||= current_admin }
    end
  end
end
