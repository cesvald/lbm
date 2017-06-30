class AddCurrencyToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :currency_id, :integer, default: 1
    add_index  :channels, :currency_id
  end
end
