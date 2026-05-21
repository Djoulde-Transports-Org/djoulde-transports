class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.string  :documentable_type, null: false
      t.bigint  :documentable_id,   null: false
      t.references :uploaded_by, foreign_key: { to_table: :users }
      t.string  :title, null: false
      t.integer :doc_type, default: 0, null: false
      t.date    :issued_on
      t.date    :expires_on

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :documents, [ :documentable_type, :documentable_id ],
              name: "index_documents_on_documentable"
    add_index :documents, :expires_on
    add_index :documents, :discarded_at
    add_index :documents, :discarded_by_id

    add_foreign_key :documents, :users, column: :discarded_by_id
  end
end
