# -*- encoding : utf-8 -*-
class Channel < ActiveRecord::Base
  extend CatarseAutoHtml

  attr_accessible :description, :name, :permalink, :email, :twitter, :facebook, :website, :image, :video_url, :how_it_works, :banner_url, :banner_top_url, :banner_bottom_url, :matchfunding_factor, :matchfunding_percentage, :matchfunding_user, :matchfunding_user_id, :matchfunding_maximum, :matchfunding_maximum_per_project, :show_drafts, :legend, :receive_projects, :funding_channel, :group_subdomains, :finish_once_reached_goal, :background_color, :banner_background_color, :project_background_color, :confirm_backer_email_paragraph, :home_page
  schema_associations

  validates_presence_of :name, :description, :permalink
  validates_uniqueness_of :permalink
  validates :description, length: { maximum: 140 }

  has_and_belongs_to_many :projects,  order: "online_date desc"

  has_and_belongs_to_many :subscribers
  has_and_belongs_to_many :trustees, class_name: :User, join_table: :channels_trustees

  has_many :backers, through: :projects
  
  has_many :phases
  
  belongs_to :matchfunding_user, class_name: :User

  scope :home_page, ->() { where("home_page").order('random()') }
  scope :not_receive_projects, -> { where(receive_projects: false) }
  scope :receive_projects, -> { where(receive_projects: true) }
  scope :visible, -> { where(visible: true) }
  scope :other_channels, ->(exclude_ids){
    visible.where("coalesce(id NOT IN (?), true)", exclude_ids).order('random()')
  }


  delegate :display_pledged_total, :display_video_thumbnail, :display_video_embed_url,  to: :decorator

  catarse_auto_html_for field: :how_it_works, video_width: 600, video_height: 403
  catarse_auto_html_for field: :legend, video_width: 600, video_height: 403

  # Links to channels should be their permalink
  def to_param; self.permalink end
  
  # Using decorators
  def decorator
    @decorator ||= ChannelDecorator.new(self)
  end

  def matchfunding_total
    self.backers.confirmed.matchfunding.where(matchfunding_channel_id: self.id).sum(:value)
  end

  def pledged_total
    self.backers.confirmed.sum(:value)
  end

  def projects_total
    self.projects.count
  end

  def group_channels
    return unless self.group_subdomains.present?
    subdomains = self.group_subdomains.split(',').map &:strip
    Channel.where(permalink: subdomains)
  end

  def parent_channel
    Channel.where("group_subdomains LIKE ?", "%#{self.permalink}%").first
  end

  def video
    @video ||= VideoInfo.get(self.video_url) if self.video_url.present?
  end
  
  def funding_channel?
    funding_channel
  end
end
