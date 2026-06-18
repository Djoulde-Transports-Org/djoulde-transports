# frozen_string_literal: true

ActiveAdmin.register BillingStatement do
  menu parent: "Billing", priority: 1

  AdminResources::Discardable.install(self)

  # Totals are derived from the kept line items (recalculate_total!), so they
  # are shown read-only here rather than edited by hand.
  permit_params :number, :month, :status, :issued_on, :due_on

  filter :number
  filter :status, as: :select, collection: BillingStatement.statuses.keys
  filter :month
  filter :issued_on

  index do
    selectable_column
    id_column
    column :number
    column :month
    column :status
    column :grand_total
    column :issued_on
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :number
      row :month
      row :status
      row :starts_on
      row :ends_on
      row :issued_on
      row :due_on
      row :total_amount
      row :total_tva
      row :grand_total
      row :created_at
      row :discarded_at
      row("Discarded by") { |statement| statement.discarded_by&.email }
    end
    panel "Line items" do
      table_for billing_statement.billing_line_items.kept do
        column(:id) { |item| link_to item.id, admin_billing_line_item_path(item) }
        column :trip
        column :amount
        column :tva
      end
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :number
      f.input :month, as: :string, input_html: {type: "date"}
      f.input :status, as: :select, collection: BillingStatement.statuses.keys
      f.input :issued_on, as: :string, input_html: {type: "date"}
      f.input :due_on, as: :string, input_html: {type: "date"}
    end
    f.actions
  end
end
