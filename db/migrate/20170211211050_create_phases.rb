class CreatePhases < ActiveRecord::Migration
  def change
    create_table :phases do |t|
      t.date :started_at, index: true
      t.string :title
      t.string :subtitle
      t.text :description
      t.belongs_to :channel

      t.timestamps
    end
    add_index :phases, :channel_id
  end
end
