class RemoveFundingFromChannels < ActiveRecord::Migration
  def change
    remove_column :channels, :funding_channel
  end
end
