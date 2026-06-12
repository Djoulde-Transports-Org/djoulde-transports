class AddMissingQuantityToDeliveryNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :delivery_notes, :missing_quantity_liters, :decimal, precision: 12, scale: 2, default: 0, null: false
  end
end
