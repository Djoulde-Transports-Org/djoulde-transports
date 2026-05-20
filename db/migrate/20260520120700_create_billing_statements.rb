class CreateBillingStatements < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_statements do |t|
      t.references :billing_period, null: false, foreign_key: true
      t.references :customer, foreign_key: { to_table: :users }
      t.string  :number, null: false
      t.date    :issued_on
      t.date    :due_on
      t.integer :status, default: 0, null: false
      t.integer :total_cents, default: 0, null: false

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :billing_statements, :number, unique: true
    add_index :billing_statements, :status
    add_index :billing_statements, :discarded_at
    add_index :billing_statements, :discarded_by_id

    add_foreign_key :billing_statements, :users, column: :discarded_by_id
  end
end
