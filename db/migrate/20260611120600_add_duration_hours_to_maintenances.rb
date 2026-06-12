class AddDurationHoursToMaintenances < ActiveRecord::Migration[8.1]
  def change
    add_column :maintenances, :duration_hours, :decimal, precision: 8, scale: 2
  end
end
