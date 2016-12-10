# -*- encoding : utf-8 -*-
class AddReceiveProjectsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :receive_projects, :boolean, default: true
  end
end
