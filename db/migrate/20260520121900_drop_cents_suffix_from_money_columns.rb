class DropCentsSuffixFromMoneyColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :routes,             :rate_cents,         :rate
    rename_column :maintenances,       :cost_cents,         :cost

    rename_column :billing_line_items, :amount_cents,       :amount
    rename_column :billing_line_items, :tva_cents,          :tva
    rename_column :billing_line_items, :rate_cents,         :rate

    rename_column :billing_statements, :total_amount_cents, :total_amount
    rename_column :billing_statements, :total_tva_cents,    :total_tva
    rename_column :billing_statements, :grand_total_cents,  :grand_total
  end
end
