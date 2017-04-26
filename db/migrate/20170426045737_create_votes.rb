class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.belongs_to :iniciative
      t.belongs_to :user
    end
    
    add_index :votes, :iniciative_id
    add_index :votes, :user_id
  end
end
