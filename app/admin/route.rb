# frozen_string_literal: true

ActiveAdmin.register Route do
  menu parent: "Operations", priority: 1

  AdminResources::Discardable.install(self)

  permit_params :origin, :destination, :rate

  filter :origin
  filter :destination
  filter :rate
  filter :created_at

  index do
    selectable_column
    id_column
    column :origin
    column :destination
    column :rate
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :origin
      row :destination
      row :rate
      row :created_at
      row :discarded_at
      row("Discarded by") { |route| route.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :origin
      f.input :destination
      f.input :rate
    end
    f.actions
  end
end
