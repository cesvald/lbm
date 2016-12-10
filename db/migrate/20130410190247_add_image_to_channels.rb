# -*- encoding : utf-8 -*-
class AddImageToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :image, :string
  end
end
