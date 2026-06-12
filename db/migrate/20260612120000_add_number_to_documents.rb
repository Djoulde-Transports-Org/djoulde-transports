class AddNumberToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :number, :string, null: false
  end
end
