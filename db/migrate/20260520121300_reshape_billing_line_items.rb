class ReshapeBillingLineItems < ActiveRecord::Migration[8.1]
  def up
    remove_column :billing_line_items, :quantity
    remove_column :billing_line_items, :unit_price_cents

    change_column_null :billing_line_items, :trip_id, false

    add_index :billing_line_items, [ :billing_statement_id, :trip_id ], unique: true,
              name: "index_billing_line_items_on_statement_and_trip"
  end

  def down
    remove_index :billing_line_items, name: "index_billing_line_items_on_statement_and_trip"

    change_column_null :billing_line_items, :trip_id, true

    add_column :billing_line_items, :quantity, :decimal, precision: 10, scale: 2, default: 1, null: false
    add_column :billing_line_items, :unit_price_cents, :integer, null: false, default: 0
  end
end
