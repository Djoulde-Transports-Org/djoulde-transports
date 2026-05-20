class ExtendBillingLineItems < ActiveRecord::Migration[8.1]
  def up
    add_column :billing_line_items, :started_on,           :date
    add_column :billing_line_items, :delivery_note_number, :string
    add_column :billing_line_items, :origin,               :string
    add_column :billing_line_items, :destination,          :string
    add_column :billing_line_items, :quantity_gasoline_liters, :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :billing_line_items, :quantity_diesel_liters,   :decimal, precision: 12, scale: 2, default: 0, null: false
    add_column :billing_line_items, :rate_cents,           :integer, default: 0, null: false
    add_column :billing_line_items, :tva_cents,            :integer, default: 0, null: false

    remove_column :billing_line_items, :description

    add_index :billing_line_items, :delivery_note_number
  end

  def down
    remove_index  :billing_line_items, :delivery_note_number

    add_column :billing_line_items, :description, :string, null: false, default: ""

    remove_column :billing_line_items, :tva_cents
    remove_column :billing_line_items, :rate_cents
    remove_column :billing_line_items, :quantity_diesel_liters
    remove_column :billing_line_items, :quantity_gasoline_liters
    remove_column :billing_line_items, :destination
    remove_column :billing_line_items, :origin
    remove_column :billing_line_items, :delivery_note_number
    remove_column :billing_line_items, :started_on
  end
end
