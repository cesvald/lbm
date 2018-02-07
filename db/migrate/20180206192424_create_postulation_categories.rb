class CreatePostulationCategories < ActiveRecord::Migration
  def change
    create_table :postulation_categories do |t|
      t.string :name_es
      t.text :description_es
    end
  end
end
