class CreateIniciatives < ActiveRecord::Migration
  def change
    create_table :iniciatives do |t|
      t.string :name
      t.text :description
      t.integer :year
      t.text :activities
      t.string :department
      t.string :municipality
      t.text :other_municipality
      t.integer :participants_count
      t.string :zone
      t.integer :women_count
      t.integer :average_age
      t.integer :benefited_count
      t.text :web_url
      t.text :facebook_url
      t.text :blog_url
      t.text :video_url
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.string :state
      t.string :main_image
      t.decimal :lat, precision: 20, scale: 14
      t.decimal :lng, precision: 20, scale: 14
      t.belongs_to :financial_channel
      t.belongs_to :category
      t.belongs_to :project
      
      t.timestamps
    end
    add_index :iniciatives, :category_id
    add_index :iniciatives, :financial_channel_id
    #add_index :iniciatives, :project_id
  end
end
