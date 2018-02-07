class ChangeVotesFromIniciativeToFinancialProject < ActiveRecord::Migration
  def change
    remove_column :iniciatives, :vote_count
    add_column :financial_projects, :vote_count, :integer, default: 0
    remove_index :votes, :iniciative_id
    remove_column :votes, :iniciative_id
    add_column :votes, :financial_project_id, :integer
    add_index :votes, :financial_project_id
  end
end
