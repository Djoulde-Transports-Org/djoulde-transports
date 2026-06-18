# frozen_string_literal: true

ActiveAdmin.register BillingLineItem do
  menu parent: "Billing", priority: 2

  AdminResources::Discardable.install(self)

  permit_params :billing_statement_id, :trip_id, :amount, :tva, :rate,
    :gasoline_quantity, :diesel_quantity, :origin, :destination,
    :delivery_note_number, :started_on

  filter :billing_statement
  filter :trip
  filter :delivery_note_number
  filter :started_on

  index do
    selectable_column
    id_column
    column :billing_statement
    column :trip
    column :origin
    column :destination
    column :amount
    column :tva
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :billing_statement
      row :trip
      row :delivery_note_number
      row :origin
      row :destination
      row :gasoline_quantity
      row :diesel_quantity
      row :rate
      row :amount
      row :tva
      row :started_on
      row :created_at
      row :discarded_at
      row("Discarded by") { |item| item.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :billing_statement
      f.input :trip
      f.input :delivery_note_number
      f.input :origin
      f.input :destination
      f.input :gasoline_quantity
      f.input :diesel_quantity
      f.input :rate
      f.input :amount
      f.input :tva
      f.input :started_on, as: :string, input_html: {type: "date"}
    end
    f.actions
  end
end
