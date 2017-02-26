class CreateIniciatives < ActiveRecord::Migration
  def change
    create_table :iniciatives do |t|
      t.string :name
      t.belongs_to :category
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
      t.belongs_to :financial_channel

      t.timestamps
    end
    add_index :iniciatives, :category_id
    add_index :iniciatives, :financial_channel_id
  end
end
