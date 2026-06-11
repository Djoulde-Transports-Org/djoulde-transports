class RenameAndIntegerizeFuelQuantities < ActiveRecord::Migration[8.1]
  def up
    rename_column :tanks, :capacity_liters, :capacity

    rename_column :delivery_notes, :quantity_gasoline_liters, :gasoline_quantity
    rename_column :delivery_notes, :quantity_diesel_liters,   :diesel_quantity
    rename_column :delivery_notes, :missing_quantity_liters,  :missing_quantity
    change_column :delivery_notes, :gasoline_quantity, :integer, default: 0, null: false
    change_column :delivery_notes, :diesel_quantity,   :integer, default: 0, null: false
    change_column :delivery_notes, :missing_quantity,  :integer, default: 0, null: false

    rename_column :billing_line_items, :quantity_gasoline_liters, :gasoline_quantity
    rename_column :billing_line_items, :quantity_diesel_liters,   :diesel_quantity
    change_column :billing_line_items, :gasoline_quantity, :integer, default: 0, null: false
    change_column :billing_line_items, :diesel_quantity,   :integer, default: 0, null: false
  end

  def down
    change_column :billing_line_items, :gasoline_quantity, :decimal, precision: 12, scale: 2, default: 0, null: false
    change_column :billing_line_items, :diesel_quantity,   :decimal, precision: 12, scale: 2, default: 0, null: false
    rename_column :billing_line_items, :gasoline_quantity, :quantity_gasoline_liters
    rename_column :billing_line_items, :diesel_quantity,   :quantity_diesel_liters

    change_column :delivery_notes, :gasoline_quantity, :decimal, precision: 12, scale: 2, default: 0, null: false
    change_column :delivery_notes, :diesel_quantity,   :decimal, precision: 12, scale: 2, default: 0, null: false
    change_column :delivery_notes, :missing_quantity,  :decimal, precision: 12, scale: 2, default: 0, null: false
    rename_column :delivery_notes, :gasoline_quantity, :quantity_gasoline_liters
    rename_column :delivery_notes, :diesel_quantity,   :quantity_diesel_liters
    rename_column :delivery_notes, :missing_quantity,  :missing_quantity_liters

    rename_column :tanks, :capacity, :capacity_liters
  end
end
