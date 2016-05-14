# -*- encoding : utf-8 -*-
class AddGroupSubdomainsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :group_subdomains, :text
  end
end
