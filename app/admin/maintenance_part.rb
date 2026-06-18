# frozen_string_literal: true

ActiveAdmin.register MaintenancePart do
  menu parent: "Fleet", priority: 4

  AdminResources::Discardable.install(self)

  permit_params :maintenance_id, :name, :price

  filter :name
  filter :maintenance
  filter :price

  index do
    selectable_column
    id_column
    column :name
    column :maintenance
    column :price
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :maintenance
      row :price
      row :created_at
      row :discarded_at
      row("Discarded by") { |part| part.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :maintenance
      f.input :name
      f.input :price
    end
    f.actions
  end
end
