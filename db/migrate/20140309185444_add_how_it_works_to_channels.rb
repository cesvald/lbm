# -*- encoding : utf-8 -*-
class AddHowItWorksToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :how_it_works, :text
  end
end
