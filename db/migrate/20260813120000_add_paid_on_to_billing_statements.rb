class AddPaidOnToBillingStatements < ActiveRecord::Migration[8.1]
  def change
    add_column :billing_statements, :paid_on, :date
  end
end
