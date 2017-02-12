class Phase < ActiveRecord::Base
  belongs_to :channel
  
  attr_accessible :description, :started_at, :title, :channel_id
  
  default_scope { order('started_at ASC') }
  
end