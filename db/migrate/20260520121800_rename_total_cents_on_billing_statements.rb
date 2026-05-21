class RenameTotalCentsOnBillingStatements < ActiveRecord::Migration[8.1]
  def change
    rename_column :billing_statements, :total_cents, :total_amount_cents
  end
end
