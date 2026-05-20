class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.string  :origin,      null: false
      t.string  :destination, null: false
      t.integer :rate_cents,  null: false

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :routes, [ :origin, :destination ], unique: true,
              name: "index_routes_on_origin_and_destination"
    add_index :routes, :discarded_at
    add_index :routes, :discarded_by_id

    add_foreign_key :routes, :users, column: :discarded_by_id
  end
end
