class CreateBillingLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_line_items do |t|
      t.references :billing_statement, null: false, foreign_key: true
      t.references :trip, foreign_key: true
      t.string  :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, default: 1, null: false
      t.integer :unit_price_cents, null: false
      t.integer :amount_cents, null: false

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :billing_line_items, :discarded_at
    add_index :billing_line_items, :discarded_by_id

    add_foreign_key :billing_line_items, :users, column: :discarded_by_id
  end
end
