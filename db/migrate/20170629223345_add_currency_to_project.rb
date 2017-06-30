class AddCurrencyToProject < ActiveRecord::Migration
  def change
    add_column :projects, :currency_id, :integer, default: 1
    add_index  :projects, :currency_id
  end
end
