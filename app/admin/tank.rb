# frozen_string_literal: true

ActiveAdmin.register Tank do
  menu parent: "Fleet", priority: 2

  AdminResources::Discardable.install(self)

  permit_params :plate_number, :vin, :make, :model, :year, :capacity, :status, :truck_id

  filter :plate_number
  filter :truck
  filter :status, as: :select, collection: Tank.statuses.keys
  filter :created_at

  index do
    selectable_column
    id_column
    column :plate_number
    column :truck
    column :capacity
    column :status
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :plate_number
      row :vin
      row :make
      row :model
      row :year
      row :capacity
      row :status
      row :truck
      row :created_at
      row :discarded_at
      row("Discarded by") { |tank| tank.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :truck
      f.input :plate_number
      f.input :vin
      f.input :make
      f.input :model
      f.input :year
      f.input :capacity
      f.input :status, as: :select, collection: Tank.statuses.keys
    end
    f.actions
  end
end
