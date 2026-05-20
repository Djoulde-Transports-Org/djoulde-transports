class AddTotalsToBillingStatements < ActiveRecord::Migration[8.1]
  def change
    add_column :billing_statements, :total_tva_cents,   :integer, default: 0, null: false
    add_column :billing_statements, :grand_total_cents, :integer, default: 0, null: false
  end
end
