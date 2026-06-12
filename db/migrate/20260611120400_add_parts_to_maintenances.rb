class AddPartsToMaintenances < ActiveRecord::Migration[8.1]
  def change
    add_column :maintenances, :parts, :json
  end
end
