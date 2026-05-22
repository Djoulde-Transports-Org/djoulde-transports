# frozen_string_literal: true

class CreateTanksAndLinkTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :tanks do |t|
      t.string  :plate_number,     null: false
      t.string  :vin
      t.string  :make
      t.string  :model
      t.integer :year
      t.integer :capacity_liters,  null: false
      t.integer :status,           null: false, default: 0
      t.references :truck,         null: false, foreign_key: true, index: { unique: true }
      t.datetime :discarded_at
      t.references :discarded_by,  foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :tanks, :plate_number, unique: true
    add_index :tanks, :vin,          unique: true
    add_index :tanks, :discarded_at

    remove_column :trucks, :capacity_kg, :integer

    add_reference :trips, :tank, null: false, foreign_key: true
  end
end
