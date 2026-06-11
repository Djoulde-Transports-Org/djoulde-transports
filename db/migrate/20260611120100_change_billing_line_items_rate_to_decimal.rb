# frozen_string_literal: true

# A billing line item snapshots the route's rate at billing time. Now that a
# route rate can carry a decimal part, the snapshot must too.
class ChangeBillingLineItemsRateToDecimal < ActiveRecord::Migration[8.1]
  def up
    change_column :billing_line_items, :rate, :decimal, precision: 12, scale: 2, default: 0, null: false
  end

  def down
    change_column :billing_line_items, :rate, :integer, default: 0, null: false
  end
end
