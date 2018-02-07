class AddPostulationFieldsToFinancialProjects < ActiveRecord::Migration
  def change
    add_column :financial_projects, :organization_name, :string
    add_column :financial_projects, :hope_transform, :text
    add_column :financial_projects, :activities, :text
    add_column :financial_projects, :benefited_indirect_count, :integer
    add_column :financial_projects, :convocation_description, :text
    add_column :financial_projects, :counterpart_contributions, :text
    add_column :financial_projects, :results_description, :text
    add_column :financial_projects, :organization_support, :string
    add_column :financial_projects, :postulation_category, :integer
    add_column :financial_projects, :other_municipality, :text
    add_column :financial_projects, :budget, :string
  end
end
