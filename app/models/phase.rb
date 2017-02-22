class Phase < ActiveRecord::Base
  belongs_to :financial_channel
  
  attr_accessible :description, :started_at, :title, :financial_channel_id
  
  default_scope { order('started_at ASC') }
  
end