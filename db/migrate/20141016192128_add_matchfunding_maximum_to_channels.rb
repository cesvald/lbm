# -*- encoding : utf-8 -*-
class AddMatchfundingMaximumToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :matchfunding_maximum, :float
  end
end
