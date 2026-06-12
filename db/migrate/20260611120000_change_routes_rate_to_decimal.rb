# frozen_string_literal: true

class ChangeRoutesRateToDecimal < ActiveRecord::Migration[8.1]
  def up
    change_column :routes, :rate, :decimal, precision: 12, scale: 2, null: false
  end

  def down
    change_column :routes, :rate, :integer, null: false
  end
end
