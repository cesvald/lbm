class Picture < ActiveRecord::Base
  attr_accessible :picture, :project_id
  validates_presence_of :picture
  mount_uploader :picture, LogoUploader
  belongs_to :project
end
