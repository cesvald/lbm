class AddFinancialChannelToPhase < ActiveRecord::Migration
  def change
    add_column :phases, :financial_channel_id, :integer
    add_index :phases, :financial_channel_id
  end
end
