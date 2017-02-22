class CreateFinancialChannels < ActiveRecord::Migration
  def change
      create_table :financial_channels do |t|
        t.belongs_to :channel
        t.timestamps
      end
      add_index :financial_channels, :channel_id
  end
end
