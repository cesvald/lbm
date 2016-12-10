# -*- encoding : utf-8 -*-
class AddHomePageToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :home_page, :boolean
  end
end
