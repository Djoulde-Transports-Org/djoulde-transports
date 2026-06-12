class SplitMaintenanceDurationIntoActualAndEstimated < ActiveRecord::Migration[8.1]
  def change
    rename_column :maintenances, :duration_hours, :actual_duration_hours
    add_column :maintenances, :estimated_duration_hours, :decimal, precision: 8, scale: 2
  end
end
