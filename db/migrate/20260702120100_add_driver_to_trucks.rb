# frozen_string_literal: true

class AddDriverToTrucks < ActiveRecord::Migration[8.0]
  def change
    add_reference :trucks, :driver, null: true, foreign_key: {to_table: :employees},
                  index: {unique: true}
  end
end
