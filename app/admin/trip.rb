# frozen_string_literal: true

ActiveAdmin.register Trip do
  menu parent: "Operations", priority: 2

  AdminResources::Discardable.install(self)

  permit_params :truck_id, :tank_id, :route_id, :driver_id, :status,
    :scheduled_start_at, :scheduled_end_at, :actual_start_at, :actual_end_at,
    :distance_km, :cargo_description

  filter :truck
  filter :route
  filter :status, as: :select, collection: Trip.statuses.keys
  filter :scheduled_start_at
  filter :actual_start_at

  index do
    selectable_column
    id_column
    column :truck
    column :route
    column("Origin") { |trip| trip.origin }
    column("Destination") { |trip| trip.destination }
    column("Gasoline (L)") { |trip| trip.delivery_note&.gasoline_quantity }
    column("Diesel (L)") { |trip| trip.delivery_note&.diesel_quantity }
    column("Delivery note") { |trip| link_to(trip.delivery_note.number, admin_delivery_note_path(trip.delivery_note)) if trip.delivery_note }
    column :status
    column :scheduled_start_at
    column :actual_start_at
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :truck
      row :tank
      row :route
      row("Origin") { |trip| trip.origin }
      row("Destination") { |trip| trip.destination }
      row("Gasoline quantity (L)") { |trip| trip.delivery_note&.gasoline_quantity }
      row("Diesel quantity (L)") { |trip| trip.delivery_note&.diesel_quantity }
      row("Delivery note") { |trip| link_to(trip.delivery_note.number, admin_delivery_note_path(trip.delivery_note)) if trip.delivery_note }
      row("Driver") { |trip| trip.driver&.email }
      row :status
      row :scheduled_start_at
      row :scheduled_end_at
      row :actual_start_at
      row :actual_end_at
      row :distance_km
      row :cargo_description
      row :created_at
      row :discarded_at
      row("Discarded by") { |trip| trip.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :truck
      f.input :tank
      f.input :route
      f.input :driver, as: :select, collection: User.order(:email).pluck(:email, :id)
      f.input :status, as: :select, collection: Trip.statuses.keys
      f.input :scheduled_start_at, as: :datetime_select
      f.input :scheduled_end_at, as: :datetime_select
      f.input :actual_start_at, as: :datetime_select
      f.input :actual_end_at, as: :datetime_select
      f.input :distance_km
      f.input :cargo_description
    end
    f.actions
  end
end
