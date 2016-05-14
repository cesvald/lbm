# -*- encoding : utf-8 -*-
class AddBankingDataFileToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :banking_data_file, :string
  end
end
