class AddIniciativeToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :iniciative_id, :integer
  end
end
