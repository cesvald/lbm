# -*- encoding : utf-8 -*-
class RenameNameToNamePt < ActiveRecord::Migration
  def change
   rename_column :categories, :name, :name_pt
  end
end
