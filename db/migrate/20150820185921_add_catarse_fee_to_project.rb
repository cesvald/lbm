class AddCatarseFeeToProject < ActiveRecord::Migration
  def change
  	add_column :projects, :catarse_fee, :float, precision: 3 , scale: 2
  end
end