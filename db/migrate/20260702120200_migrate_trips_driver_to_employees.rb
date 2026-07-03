# frozen_string_literal: true

class MigrateTripsDriverToEmployees < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :trips, column: :driver_id, if_exists: true
    # Existing driver_id values referenced users.id; employees table is empty at this point
    # so clear stale references before adding the new FK constraint.
    execute "UPDATE trips SET driver_id = NULL WHERE driver_id IS NOT NULL"
    add_foreign_key :trips, :employees, column: :driver_id
  end

  def down
    remove_foreign_key :trips, column: :driver_id
    add_foreign_key :trips, :users, column: :driver_id
  end
end
