require 'state_machine'
class FinancialChannel < ActiveRecord::Base
	belongs_to :channel
	has_many :phases
	
	state_machine :state, initial: :summoning do
		state :summoning, value: 'summoning'
		state :applying, value: 'applying'
		state :selecting, value: 'selecting'
		state :announced, value: 'announced'
		
		event :close_summoning do
			transition :summoning => :applaying
		end

		event :close_applaying do
			transition :applaying => :selecting
		end

		event :announce do
			transition :selecting => :announced
		end

		after_transition :selecting => :announced, do: :after_selecting_to_announced
	end
	
	def self.find_by_channel_permalink(permalink)
		FinancialChannel.joins(:channel).where(permalink: permalink)
	end
	
	def after_selecting_to_announced
		channel.projects.each do |project|
			project.finish
		end
	end
end