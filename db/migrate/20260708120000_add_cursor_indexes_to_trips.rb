# frozen_string_literal: true

class AddCursorIndexesToTrips < ActiveRecord::Migration[8.0]
  def change
    add_index :trips, [:status, :scheduled_start_at, :id]
    add_index :trips, [:truck_id, :scheduled_start_at, :id]
    add_index :trips, [:driver_id, :scheduled_start_at, :id]
  end
end
