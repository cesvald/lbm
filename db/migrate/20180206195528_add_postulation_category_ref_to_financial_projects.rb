class AddPostulationCategoryRefToFinancialProjects < ActiveRecord::Migration
  def change
    add_column :financial_projects, :postulation_category_id, :integer
    add_index  :financial_projects, :postulation_category_id
  end
end