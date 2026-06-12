class AddStateAndRenameDurationsOnMaintenances < ActiveRecord::Migration[8.1]
  def change
    add_column :maintenances, :state, :integer, default: 0, null: false

    rename_column :maintenances, :actual_duration_hours, :actual_duration
    rename_column :maintenances, :estimated_duration_hours, :estimated_duration
  end
end
