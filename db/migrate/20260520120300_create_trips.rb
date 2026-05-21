class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.references :truck,  null: false, foreign_key: true
      t.references :driver, foreign_key: { to_table: :users }
      t.string  :origin,      null: false
      t.string  :destination, null: false
      t.decimal :distance_km, precision: 10, scale: 2
      t.integer :status, default: 0, null: false
      t.datetime :scheduled_start_at
      t.datetime :scheduled_end_at
      t.datetime :actual_start_at
      t.datetime :actual_end_at
      t.text :cargo_description

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :trips, :status
    add_index :trips, :discarded_at
    add_index :trips, :discarded_by_id

    add_foreign_key :trips, :users, column: :discarded_by_id
  end
end
