class MoveIniciativeFromProjectToFinancialProject < ActiveRecord::Migration
  def up
    remove_index :iniciatives, :project_id
    remove_column :iniciatives, :project_id
    add_column :financial_projects, :iniciative_id, :integer
    add_index :financial_projects, :iniciative_id
  end

  def down
    remove_index :financial_projects, :iniciative_id
    remove_column :financial_projects, :iniciative_id
    add_column :iniciatives, :project_id, :integer
    add_index :iniciatives, :project_id
  end
end
