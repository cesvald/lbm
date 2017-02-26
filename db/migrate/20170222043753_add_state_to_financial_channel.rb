class AddStateToFinancialChannel < ActiveRecord::Migration
  def change
    add_column :financial_channels, :state, :string
  end
end