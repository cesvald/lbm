# -*- encoding : utf-8 -*-
class AddMatchfundingToBackers < ActiveRecord::Migration
  def change
    add_column :backers, :matchfunding, :boolean
  end
end
