class AddUniqueIndexOnDocumentsNumber < ActiveRecord::Migration[8.1]
  def change
    add_index :documents, :number, unique: true
  end
end
