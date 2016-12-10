# -*- encoding : utf-8 -*-
class AddIndexToPaymentNotificationOnBackerId < ActiveRecord::Migration
  def change
    add_index :payment_notifications, :backer_id
  end
end
