# -*- encoding : utf-8 -*-
require 'state_machine'
class Project < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include PgSearch
  extend CatarseAutoHtml

  #images
  mount_uploader :uploaded_image, LogoUploader
  mount_uploader :image, LogoUploader
  mount_uploader :video_thumbnail, LogoUploader

  #files
  mount_uploader :identification_file, DocumentUploader
  mount_uploader :rut_file, DocumentUploader
  mount_uploader :comercial_file, DocumentUploader
  mount_uploader :bank_certificate_file, DocumentUploader
  mount_uploader :banking_data_file, DocumentUploader

  delegate :display_status, :display_progress, :display_image, :display_icon_category, :display_expires_at,
    :display_pledged, :display_goal, :remaining_days, :display_video_embed_url, :display_video_thumbnail, :display_mark, :progress_bar, :successful_flag, :display_earnings, :display_pledged_platform_discount,
    to: :decorator

  schema_associations
  belongs_to :user
  belongs_to :currency
  
  has_many :backers, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :updates, dependent: :destroy
  has_many :notifications, dependent: :delete_all
  has_many :pictures, dependent: :destroy
  has_and_belongs_to_many :channels
  
  has_one :project_total
  has_one :iniciative
  has_one :financial_project
  
  accepts_nested_attributes_for :financial_project
  accepts_nested_attributes_for :rewards
  accepts_nested_attributes_for :pictures

  catarse_auto_html_for field: :about, video_width: 600, video_height: 403
  catarse_auto_html_for field: :history, video_width: 600, video_height: 403
  catarse_auto_html_for field: :cause, video_width: 600, video_height: 403
  catarse_auto_html_for field: :description, video_width: 600, video_height: 403
  catarse_auto_html_for field: :impact, video_width: 600, video_height: 403
  catarse_auto_html_for field: :budget, video_width: 600, video_height: 403
  catarse_auto_html_for field: :implementation, video_width: 600, video_height: 403

  pg_search_scope :pg_search, against: [
      [:name, 'A'],
      [:headline, 'B'],
      [:about, 'C']
    ],
    associated_against:  {user: [:name, :address_city ]},
    using: {tsearch: {dictionary: "portuguese"}},
    ignoring: :accents

  scope :not_deleted_projects, ->() { where("projects.state <> 'deleted'") }
  scope :by_progress, ->(progress) { joins(:project_total).where("project_totals.pledged >= projects.goal*?", progress.to_i/100.to_f) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_not_state, ->(state) { where('state IS NOT ?', state)  }
  scope :by_channel, ->(channel_id) { where("id IN (SELECT DISTINCT project_id FROM channels_projects WHERE channel_id = #{channel_id})") }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_permalink, ->(p) { where("lower(permalink) = lower(?)", p) }
  scope :by_category_id, ->(id) { where(category_id: id) }
  scope :by_currency_id, ->(currency_id) { where(currency_id: currency_id) }
  scope :by_user_email, ->(email) { joins(:user).where("users.email = ?", email)}
  scope :name_contains, ->(term) { where("unaccent(upper(name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.full_name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :order_table, ->(sort) {
    if sort == 'desc'
      order('goal desc')
    elsif sort == 'asc'
      order('goal asc')
    else
      order('projects.created_at desc')
    end
  }
  
  scope :near_of, ->(address_state) { joins(:user).where("lower(users.address_state) = lower(?)", address_state) }
  scope :visible, where("projects.state NOT IN ('draft', 'rejected', 'deleted')")
  scope :visible_or_draft, where("projects.state NOT IN ('rejected', 'deleted')")
  scope :financial, where("(projects.expires_at > current_timestamp - '15 days'::interval) AND (state in ('online', 'successful', 'waiting_funds'))")
  scope :recommended, where(recommended: true)
  scope :expired, where("projects.expires_at < current_timestamp")
  scope :not_expired, where("projects.expires_at >= current_timestamp")
  scope :expiring, not_expired.where("projects.expires_at <= (current_timestamp + interval '2 weeks')")
  scope :not_expiring, not_expired.where("NOT (projects.expires_at <= (current_timestamp + interval '2 weeks'))")
  scope :recent, where("current_timestamp - projects.online_date <= '30 days'::interval")
  scope :successful, where(state: 'successful')
  scope :online, where(state: 'online')
  scope :launched, where('state <> ? AND state <> ? AND state <> ? AND state <> ?', :draft, :reviewed, :rejected, :deleted)
  scope :partial_successful, where(state: 'partial_successful')
  scope :recommended_for_home, ->{
    includes(:user, :category, :project_total).
    recommended.
    visible.
    not_expired.
    order('random()').
    limit(3)
  }
  scope :order_for_search, ->{ reorder("
                                     CASE projects.state
                                     WHEN 'online' THEN 1
                                     WHEN 'waiting_funds' THEN 2
                                     WHEN 'successful' THEN 3
                                     WHEN 'failed' THEN 4
                                     END ASC, online_date DESC, created_at DESC, id DESC") }
  scope :expiring_for_home, ->(){
    includes(:user, :category, :project_total).online.expiring.order("random()").limit(3)
  }
  scope :recent_for_home, ->(){
    includes(:user, :category, :project_total).online.order("random()").limit(3)
  }
  scope :successful_for_home, ->(){
    includes(:user, :category, :project_total).visible.successful.order('random()').limit(3)
  }
  scope :successful_for_home_excluding, ->(exclude_ids){
    includes(:user, :category, :project_total).where("coalesce(id NOT IN (?), true)", exclude_ids).visible.successful.order('random()').limit(3)
  }

  scope :backed_by, ->(user_id){
    where("id IN (SELECT project_id FROM backers b WHERE b.state = 'confirmed' AND b.user_id = ?)", user_id)
  }
  
  scope :created_on_year, ->(year) {  where("EXTRACT(year FROM created_at) = ?", year)  }
  
  attr_accessor :accepted_terms, :review_comments, :updated_by

  validates_acceptance_of :accepted_terms, on: :create

  validates :video_url, presence: true, if: ->(p) { p.state_name == 'online' }
  validates_presence_of :name, :user, :category, :about, :headline, :goal, :permalink
  validates_length_of :headline, maximum: 140
  validates_uniqueness_of :permalink, allow_blank: true, allow_nil: true, case_sensitive: false
  validates_format_of :permalink, with: /^(\w|-)*$/, allow_blank: true, allow_nil: true
  validates_format_of :video_url, with: /(https?:\/\/(www\.)?vimeo.com\/(\d+))|(^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*)|(youtu\.be\/([^\?]*))/, message: I18n.t('project.video_regex_validation'), allow_blank: true
  validates_format_of :name, with: /^[A-Za-zñÑáéíóúÁÉÍÓÚ\d\-_\s]+$/i, messapge:  I18n.t('project.name_regex_validation')
  validate :permalink_cant_be_route, allow_nil: true
  validates_numericality_of :goal, greater_than_or_equal_to: ::Configuration[:partial_goal].to_f
  
  def self.between_created_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("created_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.between_expires_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("projects.expires_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.finish_projects!
    expired.each do |resource|
      Rails.logger.info "[FINISHING PROJECT #{resource.id}] #{resource.name}"
      resource.finish
    end
  end

  def self.send_reminders!
    self.between_expires_at((Time.now - 33.days).strftime("%d/%m/%Y"), (Time.now - 27.days).strftime("%d/%m/%Y")).each do |project|
      project.remind_rewards
    end

    self.between_expires_at((Time.now - 93.days).strftime("%d/%m/%Y"), (Time.now - 87.days).strftime("%d/%m/%Y")).each do |project|
      project.remind_rewards_and_impact
    end
  end

  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
  end

  def subscribed_users
    User.subscribed_to_updates.subscribed_to_project(self.id)
  end

  def decorator
    @decorator ||= ProjectDecorator.new(self)
  end

  def expires_at
    online_date && Time.zone.parse((online_date + online_days.days).strftime("%Y-%m-%d 23:59:59"))
  end

  def video
    @video ||= VideoInfo.get(self.video_url) if self.video_url.present?
  end

  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end

  def pledged
    project_total ? project_total.pledged : 0.0
  end

  def total_backers
    project_total ? project_total.total_backers : 0
  end

  def total_payment_service_fee
    project_total ? project_total.total_payment_service_fee : 0.0
  end

  def selected_rewards
    rewards.sort_asc.where(id: backers.confirmed.select('DISTINCT(reward_id)'))
  end

  def reached_partial_goal?
    pledged >= ::Configuration[:partial_goal].to_f
  end

  def reached_goal?
    pledged >= goal
  end

  def finished?
    not online? and not draft? and not rejected?
  end

  def expired?
    expires_at && expires_at < Time.zone.now
  end

  def in_time_to_wait?
    backers.in_time_to_confirm.count > 0
  end

  def in_time?
    !expired?
  end

  def progress
    return 0 if goal == 0.0 && pledged == 0.0
    return 100 if goal == 0.0 && pledged > 0.0
    ((pledged / goal * 100).abs).round(pledged.to_i.size).to_i
  end

  def time_to_go
    ['day', 'hour', 'minute', 'second'].each do |unit|
      if expires_at.to_i >= 1.send(unit).from_now.to_i
        time = ((expires_at - Time.zone.now).abs/1.send(unit)).round
        return {time: time, unit: pluralize_without_number(time, I18n.t("datetime.prompts.#{unit}").downcase)}
      end
    end
    {time: 0, unit: pluralize_without_number(0, I18n.t('datetime.prompts.second').downcase)}
  end

  def remaining_text
    pluralize_without_number(time_to_go[:time], I18n.t('remaining_singular'), I18n.t('remaining_plural'))
  end

  def update_video_embed_url
    self.video_embed_url = self.video.embed_url if self.video.present?
  end

  def download_video_thumbnail
    if !self.video_thumbnail.present?
      self.video_thumbnail = open(self.video.thumbnail_large) if self.video_url.present? && self.video
    end
  rescue OpenURI::HTTPError => e
    Rails.logger.info "-----> #{e.inspect}"
  rescue TypeError => e
    Rails.logger.info "-----> #{e.inspect}"
  end

  def as_json(options={})
    {
      id: id,
      name: name,
      user: user,
      category: category,
      category_name: category.to_s,
      mark_image: display_mark,
      image: display_image,
      headline: truncate(headline, length: 140),
      progress: progress,
      display_progress: display_progress,
      goal: display_goal,
      pledged: display_pledged,
      created_at: created_at,
      time_to_go: time_to_go,
      remaining_text: remaining_text,
      video_url: video_url,
      embed_url: video_embed_url ? video_embed_url : (video ? video.embed_url : nil),
      url: Rails.application.routes.url_helpers.project_by_slug_path(permalink, locale: I18n.locale),
      icon_category: display_icon_category,
      full_uri: Rails.application.routes.url_helpers.project_by_slug_url(permalink, locale: I18n.locale),
      expired: expired?,
      partial_successful: partial_successful?,
      successful: successful?,
      waiting_funds: waiting_funds?,
      failed: failed?,
      state: state,
      display_status_to_box: display_status.blank? ? nil : I18n.t("project.display_status.#{display_status}").capitalize,
      display_expires_at: display_expires_at,
      in_time: in_time?,
      permalink: permalink,
      about: about_html,
      history: history_html,
      cause: cause_html,
      description: description_html,
      impact: impact_html,
      budget: budget_html,
      implementation: implementation_html,
      online_days: online_days
    }
  end

  def pending_backers_reached_the_goal?
    (pledged + backers.in_time_to_confirm.sum(&:value)) >= goal
  end

  def pending_backers_reached_the_partial_goal?
    (pledged + backers.in_time_to_confirm.sum(&:value)) >= ::Configuration[:partial_goal].to_f
  end

  def can_go_to_second_chance?
    false
  end

  def permalink_cant_be_route
    errors.add(:permalink, I18n.t("activerecord.errors.models.project.attributes.permalink.invalid")) if Project.permalink_on_routes?(permalink)
  end
  
  def self.permalink_on_routes?(permalink)
    permalink && self.get_routes.include?(permalink.downcase)
  end

  #NOTE: state machine things
  state_machine :state, initial: :draft do
    state :draft, value: 'draft'
    state :reviewed, value: 'reviewed'
    state :rejected, value: 'rejected'
    state :online, value: 'online'
    state :partial_successful, value: 'partial_successful'
    state :successful, value: 'successful'
    state :waiting_funds, value: 'waiting_funds'
    state :failed, value: 'failed'
    state :deleted, value: 'deleted'

    event :push_to_draft do
      transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
    end

    event :push_to_trash do
      transition [:draft, :reviewed, :rejected] => :deleted
    end

    event :review do
      transition [:draft, :reviewed] => :reviewed
    end

    event :reject do
      transition [:draft, :reviewed] => :rejected
    end

    event :approve do
      transition [:draft, :reviewed] => :online
    end

    event :finish do
      transition online: :failed,             if: ->(project) {
        project.expired? && !project.pending_backers_reached_the_partial_goal? && !project.pending_backers_reached_the_goal? && !project.can_go_to_second_chance?
      }

      transition online: :successful,      if: ->(project) {
        project.expired? && project.reached_goal? && !project.in_time_to_wait?
      }

      transition online: :partial_successful, if: ->(project) {
        project.expired? && !project.reached_goal? && project.reached_partial_goal? && !project.in_time_to_wait?
      }

      transition online: :waiting_funds,      if: ->(project) {
        project.expired? && (project.pending_backers_reached_the_partial_goal? || project.pending_backers_reached_the_goal? || project.can_go_to_second_chance?)
      }

      transition waiting_funds: :successful,  if: ->(project) {
        project.reached_goal? && !project.in_time_to_wait?
      }

      transition waiting_funds: :partial_successful,  if: ->(project) {
        !project.reached_goal? && project.reached_partial_goal? && !project.in_time_to_wait?
      }

      transition waiting_funds: :failed,      if: ->(project) {
        project.expired? && !project.reached_partial_goal? && !project.in_time_to_wait? && !project.can_go_to_second_chance?
      }

      transition waiting_funds: :waiting_funds,      if: ->(project) {
        project.expired? && !project.reached_goal? && (project.in_time_to_wait? || project.can_go_to_second_chance?)
      }
    end

    after_transition online: :waiting_funds, do: :after_transition_of_online_to_waiting_funds
    after_transition [:waiting_funds, :online] => [:successful, :failed, :partial_successful], do: :after_transition_of_wainting_funds_to_successful_or_failed
    after_transition [:draft, :reviewed] => :reviewed, do: :after_transition_of_draft_to_reviewed
    after_transition [:draft, :reviewed] => :online, do: :after_transition_of_draft_to_online
    after_transition [:draft, :reviewed] => :rejected, do: :after_transition_of_draft_to_rejected
    after_transition [:draft, :reviewed, :rejected] => :deleted, :do => :after_transition_of_draft_or_rejected_to_deleted
    after_transition any => [:failed, :successful], :do => :after_transition_of_any_to_failed_or_successful
  end

  def after_transition_of_draft_or_rejected_to_deleted
    update_attributes({ permalink: "deleted_project_#{id}"})
  end

  def after_transition_of_draft_to_reviewed
    notify_observers :notify_owner_project_review
  end

  def after_transition_of_online_to_waiting_funds
    notify_observers :notify_owner_that_project_is_waiting_funds
  end

  def after_transition_of_any_to_failed_or_successful
    notify_observers :sync_with_mailchimp
  end

  def after_transition_of_draft_to_rejected
    notify_observers :notify_owner_that_project_is_rejected
  end

  def after_transition_of_wainting_funds_to_successful_or_failed
    notify_observers :notify_users
  end

  def after_transition_of_draft_to_online
    update_attributes({ online_date: DateTime.now })
    notify_observers :notify_owner_that_project_is_online
  end

  def notify_admin_documents_ready
    notify_observers :notify_admin_documents_ready
  end

  def new_draft_recipient
    email = ::Configuration[:email_projects]
    User.where(email: email).first
  end

  def new_draft_project_notification_type
    channels.first ? :new_draft_project_channel : :new_draft_project
  end

  def new_project_received_notification_type
    channels.first ? :project_received_channel : :project_received
  end

  def actual_platform_fee
    self.platform_fee || self.catarse_fee
  end
  
  def actual_credits_fee
    self.credits_fee || 0.07
  end
  
  def matchfunding_total(channel)
    self.backers.confirmed.matchfunding.where(matchfunding_channel_id: channel.id).sum(:value)
  end

  def channels_string
    channels.map(&:name).join(', ')
  end
  
  def remind_rewards
    notify_observers :remind_owner_rewards
  end

  def remind_rewards_and_impact
    notify_observers :remind_owner_rewards_and_impact
  end
  
  def financial_channel
    channels.joins(:financial_channel).first.financial_channel
  end
  
  def financial?
    iniciative.present?
  end
  
  def channel_trustees
    User.joins(channels: :projects).where('projects.id = ?', id)
  end
  
  def final_pledge
  end
  
  def pledged_platform_discount
    pledged * actual_platform_fee
  end
  
  def earnings
    pledged - (pledged_platform_discount)
  end
  
  private
  def self.get_routes
    routes = Rails.application.routes.routes.map do |r|
      r.path.spec.to_s.split('/').second.to_s.gsub(/\(.*?\)/, '')
    end
    routes.compact.uniq
  end
end
