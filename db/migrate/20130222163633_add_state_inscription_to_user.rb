# -*- encoding : utf-8 -*-
class AddStateInscriptionToUser < ActiveRecord::Migration
  def change
    add_column :users, :state_inscription, :string
  end
end
