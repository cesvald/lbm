class AddPluralityToIniciatives < ActiveRecord::Migration
  def change
    add_column :iniciatives, :plurality, :string
  end
end
