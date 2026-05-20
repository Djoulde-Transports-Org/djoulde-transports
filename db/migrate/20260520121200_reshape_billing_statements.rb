class ReshapeBillingStatements < ActiveRecord::Migration[8.1]
  def up
    if foreign_key_exists?(:billing_statements, column: :customer_id)
      remove_foreign_key :billing_statements, column: :customer_id
    end
    if column_exists?(:billing_statements, :customer_id)
      remove_reference :billing_statements, :customer
    end

    # MySQL refuses to drop an index that backs a foreign key, so drop the FK,
    # swap the index, then put the FK back.
    if foreign_key_exists?(:billing_statements, column: :billing_period_id)
      remove_foreign_key :billing_statements, column: :billing_period_id
    end

    if index_exists?(:billing_statements, :billing_period_id, name: "index_billing_statements_on_billing_period_id")
      remove_index :billing_statements, name: "index_billing_statements_on_billing_period_id"
    end

    add_index :billing_statements, :billing_period_id, unique: true,
              name: "index_billing_statements_on_billing_period_id_unique"

    add_foreign_key :billing_statements, :billing_periods, column: :billing_period_id
  end

  def down
    if foreign_key_exists?(:billing_statements, column: :billing_period_id)
      remove_foreign_key :billing_statements, column: :billing_period_id
    end

    remove_index :billing_statements, name: "index_billing_statements_on_billing_period_id_unique"
    add_index    :billing_statements, :billing_period_id,
                 name: "index_billing_statements_on_billing_period_id"

    add_foreign_key :billing_statements, :billing_periods, column: :billing_period_id

    add_reference :billing_statements, :customer, foreign_key: { to_table: :users }
  end
end
