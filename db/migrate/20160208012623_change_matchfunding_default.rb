class ChangeMatchfundingDefault < ActiveRecord::Migration
  def change
  	change_column_default(:backers, :matchfunding, false)
  	change_column :backers, :matchfunding, :boolean, :null => false
  end
end
