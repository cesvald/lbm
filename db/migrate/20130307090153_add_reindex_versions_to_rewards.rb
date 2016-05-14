# -*- encoding : utf-8 -*-
class AddReindexVersionsToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :reindex_versions, :datetime
  end
end
