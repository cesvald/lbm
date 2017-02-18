class AddFinancialToBackers < ActiveRecord::Migration
  def change
    add_column :backers, :financial, :boolean, default: false
  end
end
