class AddVisibleToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :visible, :boolean, default: false
  end
end