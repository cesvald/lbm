# -*- encoding : utf-8 -*-
class AddLegendToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :legend, :text
  end
end
