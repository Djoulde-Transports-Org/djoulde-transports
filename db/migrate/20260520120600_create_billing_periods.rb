class CreateBillingPeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_periods do |t|
      t.string  :label, null: false
      t.date    :starts_on, null: false
      t.date    :ends_on,   null: false
      t.integer :status, default: 0, null: false

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :billing_periods, :label, unique: true
    add_index :billing_periods, :starts_on
    add_index :billing_periods, :discarded_at
    add_index :billing_periods, :discarded_by_id

    add_foreign_key :billing_periods, :users, column: :discarded_by_id
  end
end
