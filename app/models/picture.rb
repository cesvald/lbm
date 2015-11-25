class Picture < ActiveRecord::Base
  attr_accessible :picture, :project_id
  mount_uploader :picture, LogoUploader
  belongs_to :project
end
