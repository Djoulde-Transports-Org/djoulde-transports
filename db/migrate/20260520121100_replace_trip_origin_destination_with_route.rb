class ReplaceTripOriginDestinationWithRoute < ActiveRecord::Migration[8.1]
  def up
    add_reference :trips, :route, foreign_key: true, null: true

    # No existing rows to backfill (ticket 10 just created this table).
    # Production data would need a one-off backfill before flipping to NOT NULL.

    change_column_null :trips, :route_id, false

    remove_column :trips, :origin
    remove_column :trips, :destination
  end

  def down
    add_column :trips, :origin,      :string
    add_column :trips, :destination, :string

    remove_reference :trips, :route, foreign_key: true
  end
end
