require 'state_machine'
class Iniciative < ActiveRecord::Base
  
  belongs_to :category
  belongs_to :financial_channel
  belongs_to :project
  
  has_many :votes, dependent: :delete_all
  has_many :users, through: :votes
  has_many :notifications, dependent: :delete_all
  mount_uploader :main_image, LogoUploader
  
  attr_accessible :state, :lat, :lng, :department, :activities, :average_age, :benefited_count, :blog_url, :contact_email, :contact_name, :contact_phone, :description, :facebook_url, :municipality, :name, :other_municipality, :participants_count, :state, :video_url, :web_url, :women_count, :year, :zone, :financial_channel, :category_id, :financial_channel_id, :accepted_terms, :main_image
  
  attr_accessor :accepted_terms
  validates_acceptance_of :accepted_terms, on: :create
  
  validates_presence_of :lat, :lng, :name, :description, :year, :activities, :department, :municipality, :participants_count, :zone, :women_count, :average_age, :benefited_count, :contact_name, :contact_email, :financial_channel_id, :contact_phone, :main_image
  
  validates_uniqueness_of :contact_email
  
  validates_format_of :contact_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  scope :by_name, ->(name) { where(name: name) }
  scope :by_channel, ->(channel_id) { joins(:financial_channel).where("financial_channels.channel_id": channel_id) }
  scope :by_contact_email, ->(email) { where(contact_email: email) }
  scope :approved, -> { where(state: 'approved') }
  
  state_machine :state, initial: :draft do
    state :draft, value: 'draft'
		state :approved, value: 'approved'
		state :rejected, value: 'rejected'
		state :confirmed, value: 'confirmed'
		
		event :approve do
			transition :draft => :approved
		end

    event :reject do
      transition :draft => :rejected
    end
    
		event :confirm do
			transition :approved => :confirmed
		end
		
		after_transition draft: :approved, do: :after_transition_of_draft_to_approved
		
	end
	
	def after_transition_of_draft_to_approved
	  notify_observers :notify_owner_that_iniciative_is_approved
	end
	
	def add_vote
	  self.vote_count = self.vote_count + 1
	end
	
	def already_voted?(user)
	  users.exists?(user.id)
	end
	
	def self.new_draft_recipient
    email = ::Configuration[:email_projects]
    User.where(email: email).first
  end
  
#Iniciative.create(:lat => 1, :lng => 1, :name => "asdf", :description => "asdf", :year => 2010, :activities => "asdf", :department => "Bolivar", :municipality => "Cartagena", :participants_count => 2, :zone => "asdf", :women_count => "asdf", :average_age => 30, :benefited_count => 20, :contact_name => "Cesar", :contact_email => "valderramago@gmail.com", :financial_channel_id => 1, :category_id => 28)	
end