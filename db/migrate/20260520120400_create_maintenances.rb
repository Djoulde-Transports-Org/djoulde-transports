class CreateMaintenances < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenances do |t|
      t.references :truck,        null: false, foreign_key: true
      t.references :performed_by, foreign_key: { to_table: :users }
      t.integer :kind, default: 0, null: false
      t.date    :performed_on, null: false
      t.text    :description
      t.integer :cost_cents
      t.integer :odometer_km

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :maintenances, :performed_on
    add_index :maintenances, :discarded_at
    add_index :maintenances, :discarded_by_id

    add_foreign_key :maintenances, :users, column: :discarded_by_id
  end
end
