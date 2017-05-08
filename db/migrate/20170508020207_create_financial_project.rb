class CreateFinancialProject < ActiveRecord::Migration
  def change
    create_table :financial_projects do |t|
      t.integer :benefited_count
      t.integer :women_count
      t.string :department
      t.string :municipality
      t.string :zone
      t.belongs_to :project
      
      t.timestamps
    end
    add_index :financial_projects, :project_id
  end
end