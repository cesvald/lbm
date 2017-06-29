class AddEthnicGroupToIniciative < ActiveRecord::Migration
  def change
    add_column :iniciatives, :ethnic_group, :string
  end
end
