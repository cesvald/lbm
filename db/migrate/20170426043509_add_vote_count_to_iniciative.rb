class AddVoteCountToIniciative < ActiveRecord::Migration
  def change
    add_column :iniciatives, :vote_count, :integer, default: 0
  end
end
