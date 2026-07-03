# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number
      t.integer :role, null: false, default: 0

      t.references :user, null: true, foreign_key: true, index: {unique: true}
      t.references :created_by, null: true, foreign_key: {to_table: :users}
      t.references :discarded_by, null: true, foreign_key: {to_table: :users}

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :employees, :discarded_at
    add_index :employees, :role
  end
end
