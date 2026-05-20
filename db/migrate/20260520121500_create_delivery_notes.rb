class CreateDeliveryNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_notes do |t|
      t.references :trip, null: false, foreign_key: true, index: { unique: true }
      t.string  :number, null: false
      t.decimal :quantity_gasoline_liters, precision: 12, scale: 2, default: 0, null: false
      t.decimal :quantity_diesel_liters,   precision: 12, scale: 2, default: 0, null: false
      t.date    :delivered_on

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :delivery_notes, :number, unique: true
    add_index :delivery_notes, :discarded_at
    add_index :delivery_notes, :discarded_by_id

    add_foreign_key :delivery_notes, :users, column: :discarded_by_id
  end
end
