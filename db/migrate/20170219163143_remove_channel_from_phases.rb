class RemoveChannelFromPhases < ActiveRecord::Migration
  def change
    remove_column :phases, :channel_id
  end
end
