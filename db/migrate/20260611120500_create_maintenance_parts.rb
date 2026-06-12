class CreateMaintenanceParts < ActiveRecord::Migration[8.1]
  def change
    remove_column :maintenances, :parts, :json

    create_table :maintenance_parts do |t|
      t.references :maintenance, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :price, null: false, default: 0
      t.datetime :discarded_at
      t.references :discarded_by, foreign_key: {to_table: :users}

      t.timestamps
    end

    add_index :maintenance_parts, :discarded_at
  end
end
