# -*- encoding : utf-8 -*-
class AddVideoUrlToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :video_url, :string
  end
end
