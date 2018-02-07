# -*- encoding : utf-8 -*-
class PostulationCategory < ActiveRecord::Base
  has_many :financial_projects
  validates_presence_of :name_es
  validates_uniqueness_of :name_es

  def self.name_array
    order('name_'+ I18n.locale.to_s + ' ASC').collect { |c| [c.send('name_' + I18n.locale.to_s), c.id] }
  end

  def to_s
    self.send('name_' + I18n.locale.to_s)
  end

end
