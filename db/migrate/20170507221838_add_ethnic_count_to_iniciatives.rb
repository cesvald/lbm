class AddEthnicCountToIniciatives < ActiveRecord::Migration
  def change
    add_column :iniciatives, :ethnic_count, :integer
  end
end
