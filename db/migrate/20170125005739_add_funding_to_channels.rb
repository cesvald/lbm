class AddFundingToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :funding_channel, :boolean
  end
end
