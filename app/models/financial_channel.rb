require 'state_machine'
class FinancialChannel < ActiveRecord::Base
	belongs_to :channel
	has_many :phases
	has_many :iniciatives
	
	state_machine :state, initial: :summoning do
		state :summoning, value: 'summoning'
		state :applying, value: 'applying'
		state :selecting, value: 'selecting'
		state :announced, value: 'announced'
		
		event :open_applying do
			transition :summoning => :applying
		end

		event :close_applying do
			transition :applying => :selecting
		end

		event :announce do
			transition :selecting => :announced
		end
		
		event :restart do
			transition :announced => :summoning
		end
		
		after_transition :selecting => :announced, do: :after_selecting_to_announced
	end
	
	def self.find_by_channel_permalink(permalink)
		FinancialChannel.joins(:channel).where(permalink: permalink)
	end
	
	def after_selecting_to_announced
		channel.projects.each do |project|
			project.online_date = DateTime.now - 1.day - (project.online_days).day
			project.save
			project.finish
		end
	end
end