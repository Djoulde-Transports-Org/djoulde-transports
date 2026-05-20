class CollapseBillingPeriodIntoStatement < ActiveRecord::Migration[8.1]
  def up
    add_column :billing_statements, :month, :date
    add_column :billing_statements, :starts_on, :date
    add_column :billing_statements, :ends_on,   :date

    # No data to migrate (ticket 10 just created these tables).

    change_column_null :billing_statements, :month,     false
    change_column_null :billing_statements, :starts_on, false
    change_column_null :billing_statements, :ends_on,   false

    add_index :billing_statements, :month, unique: true

    if foreign_key_exists?(:billing_statements, column: :billing_period_id)
      remove_foreign_key :billing_statements, column: :billing_period_id
    end
    if index_exists?(:billing_statements, :billing_period_id, name: "index_billing_statements_on_billing_period_id_unique")
      remove_index :billing_statements, name: "index_billing_statements_on_billing_period_id_unique"
    end
    remove_column :billing_statements, :billing_period_id

    if foreign_key_exists?(:billing_periods, column: :discarded_by_id)
      remove_foreign_key :billing_periods, column: :discarded_by_id
    end
    drop_table :billing_periods
  end

  def down
    create_table :billing_periods do |t|
      t.string   :label, null: false
      t.date     :starts_on, null: false
      t.date     :ends_on,   null: false
      t.integer  :status, default: 0, null: false
      t.datetime :discarded_at
      t.bigint   :discarded_by_id
      t.timestamps
    end
    add_index :billing_periods, :label,           unique: true
    add_index :billing_periods, :starts_on
    add_index :billing_periods, :discarded_at
    add_index :billing_periods, :discarded_by_id
    add_foreign_key :billing_periods, :users, column: :discarded_by_id

    add_reference :billing_statements, :billing_period, foreign_key: true
    add_index :billing_statements, :billing_period_id, unique: true,
              name: "index_billing_statements_on_billing_period_id_unique"

    remove_index  :billing_statements, :month
    remove_column :billing_statements, :ends_on
    remove_column :billing_statements, :starts_on
    remove_column :billing_statements, :month
  end
end
