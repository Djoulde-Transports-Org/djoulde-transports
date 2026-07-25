# frozen_string_literal: true

class AddStatusAndDetailsToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :address, :string
    add_column :employees, :hire_date, :date
    add_column :employees, :status, :integer, null: false, default: 0

    add_index :employees, :status
  end
end
