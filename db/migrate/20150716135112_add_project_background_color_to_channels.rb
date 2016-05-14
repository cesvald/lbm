# -*- encoding : utf-8 -*-
class AddProjectBackgroundColorToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :project_background_color, :string
  end
end
