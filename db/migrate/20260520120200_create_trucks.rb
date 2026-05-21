class CreateTrucks < ActiveRecord::Migration[8.1]
  def change
    create_table :trucks do |t|
      t.string  :plate_number, null: false
      t.string  :vin
      t.string  :make
      t.string  :model
      t.integer :year
      t.integer :capacity_kg
      t.integer :status, default: 0, null: false
      t.references :created_by, foreign_key: { to_table: :users }

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :trucks, :plate_number, unique: true
    add_index :trucks, :vin, unique: true
    add_index :trucks, :discarded_at
    add_index :trucks, :discarded_by_id

    add_foreign_key :trucks, :users, column: :discarded_by_id
  end
end
