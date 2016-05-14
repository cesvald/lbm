# -*- encoding : utf-8 -*-
class AddUniqueIndexToConfiguration < ActiveRecord::Migration
  def change
    add_index :configurations, :name, unique: true
  end
end
