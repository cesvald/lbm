# -*- encoding : utf-8 -*-
class AddWebsiteToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :website, :string
  end
end
