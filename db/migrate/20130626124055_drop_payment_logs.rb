# -*- encoding : utf-8 -*-
class DropPaymentLogs < ActiveRecord::Migration
  def up
    execute "DROP TABLE IF EXISTS payment_logs"
  end

  def down
  end
end
