# frozen_string_literal: true

ActiveAdmin.register Maintenance do
  menu parent: "Fleet", priority: 3

  AdminResources::Discardable.install(self)

  permit_params :truck_id, :performed_by_id, :kind, :state, :performed_on,
    :cost, :odometer_km, :estimated_duration, :actual_duration, :description

  filter :truck
  filter :kind, as: :select, collection: Maintenance.kinds.keys
  filter :state, as: :select, collection: Maintenance.states.keys
  filter :performed_on

  index do
    selectable_column
    id_column
    column :truck
    column :kind
    column :state
    column :performed_on
    column :cost
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :truck
      row :kind
      row :state
      row :performed_on
      row :cost
      row :odometer_km
      row :estimated_duration
      row :actual_duration
      row("Performed by") { |m| m.performed_by&.email }
      row :description
      row :created_at
      row :discarded_at
      row("Discarded by") { |m| m.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :truck
      f.input :performed_by, as: :select, collection: User.order(:email).pluck(:email, :id)
      f.input :kind, as: :select, collection: Maintenance.kinds.keys
      f.input :state, as: :select, collection: Maintenance.states.keys
      f.input :performed_on, as: :datepicker
      f.input :cost
      f.input :odometer_km
      f.input :estimated_duration
      f.input :actual_duration
      f.input :description
    end
    f.actions
  end
end
