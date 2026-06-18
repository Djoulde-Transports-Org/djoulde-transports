# frozen_string_literal: true

ActiveAdmin.register DeliveryNote do
  menu parent: "Operations", priority: 3

  AdminResources::Discardable.install(self)

  permit_params :trip_id, :number, :delivered_on,
    :gasoline_quantity, :diesel_quantity, :missing_quantity

  filter :number
  filter :trip
  filter :delivered_on

  index do
    selectable_column
    id_column
    column :number
    column :trip
    column :delivered_on
    column("Total L") { |note| note.total_liters }
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :number
      row :trip
      row :delivered_on
      row :gasoline_quantity
      row :diesel_quantity
      row :missing_quantity
      row("Total L") { |note| note.total_liters }
      row :created_at
      row :discarded_at
      row("Discarded by") { |note| note.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :trip
      f.input :number
      f.input :delivered_on, as: :datepicker
      f.input :gasoline_quantity
      f.input :diesel_quantity
      f.input :missing_quantity
    end
    f.actions
  end
end
