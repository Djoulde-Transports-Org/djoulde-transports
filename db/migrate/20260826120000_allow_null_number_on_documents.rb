# frozen_string_literal: true

class AllowNullNumberOnDocuments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :documents, :number, true
  end
end
