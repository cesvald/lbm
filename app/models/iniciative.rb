class Iniciative < ActiveRecord::Base
  
  belongs_to :category
  belongs_to :financial_channel
  
  attr_accessible :activities, :average_age, :benefited_count, :blog_url, :contact_email, :contact_name, :contact_phone, :description, :facebook_url, :municipality, :name, :other_municipality, :participants_count, :state, :video_url, :web_url, :women_count, :year, :zone, :financial_channel, :category_id
  
  attr_accessor :accepted_terms
  validates_acceptance_of :accepted_terms, on: :create
  
end