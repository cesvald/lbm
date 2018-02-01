# -*- encoding : utf-8 -*-
require 'state_machine'
class Backer < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::DateHelper

  schema_associations

  validates_presence_of :project, :user, :value
  validate :minimum_amount
  validate :reward_must_be_from_project
  validate :value_must_be_at_least_rewards_value
  validate :should_not_back_if_maximum_backers_been_reached, on: :create
  validate :project_should_be_online, on: :create

  scope :not_deleted, ->() { where("backers.state <> 'deleted'") }
  scope :by_id, ->(id) { where(id: id) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_payment_method, ->(payment_method) { where(payment_method: payment_method) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :by_currency_id, ->(currency_id) { joins(:project).where('projects.currency_id = ?', currency_id) }
  scope :by_project_state, ->(state) { joins(:project).where("projects.state = ?", state)}
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :project_name_contains, ->(term) { joins(:project).where("unaccent(upper(projects.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :by_channel,  ->(channel_id) { where("backers.project_id IN (SELECT DISTINCT project_id FROM channels_projects WHERE channel_id = #{channel_id})") }
  scope :anonymous, where(anonymous: true)
  scope :credits, where(credits: true)
  scope :requested_refund, where(state: 'requested_refund')
  scope :refunded, where(state: 'refunded')
  scope :not_anonymous, where(anonymous: false)
  scope :confirmed, where(state: 'confirmed')
  scope :matchfunding, where(matchfunding: true)
  scope :is_matchfunding, -> (is_matchfunding) { where(matchfunding: is_matchfunding) }
  scope :not_confirmed, where("backers.state <> 'confirmed'") # used in payment engines
  scope :in_time_to_confirm, ->() { where(state: 'waiting_confirmation') }
  scope :pending_to_refund, ->() { where(state: 'requested_refund') }
  
  scope :confirmed_on_year, ->(year) {  where("EXTRACT(year FROM confirmed_at) = ?", year)  }
  
  scope :available_to_count, ->() { where("state in ('confirmed', 'requested_refund', 'refunded')") }

  scope :can_cancel, ->() {
    where(%Q{
      backers.state = 'waiting_confirmation' and
        (
          ((
            select count(1) as total_of_days
            from generate_series(created_at::date, current_date, '1 day') day
            WHERE extract(dow from day) not in (0,1)
          )  > 4)
          OR
          (
            payment_choice = 'DebitoBancario'
            AND
              (
                select count(1) as total_of_days
                from generate_series(created_at::date, current_date, '1 day') day
                WHERE extract(dow from day) not in (0,1)
              )  > 1)
        )
    })
  }

  # Backers already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{
    where(%Q{
      backers.state IN('confirmed', 'requested_refund', 'refunded') AND
      EXISTS(
        SELECT true
          FROM projects p
          WHERE p.id = backers.project_id and p.state = 'failed'
      )
    })
  }

  attr_protected :confirmed, :state

  def minimum_amount
    if value < project.currency.minimum_amount
       errors.add(:amount, "No puede ser menor de " + project.currency.display_minimum_amount)
    end
  end
  
  def self.between_values(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

  def self.between_created_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("created_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.between_confirmed_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("confirmed_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
  end

  def self.send_credits_notification
    confirmed.joins(:project).joins(:user).find_each do |backer|
      if backer.project.state == 'failed' && ((backer.project.expires_at + 1.month) < Time.now) && backer.user.credits >= backer.value
        Notification.create_notification_once(:credits_warning,
          backer.user,
          {backer_id: backer.id},
          backer: backer,
          amount: backer.user.credits
                                             )
      end
    end
  end

  def refund_deadline
    project.expires_at.to_date + 120.days
  end
  
  def available_deadline
    project.expires_at.to_date + 120.days
  end

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def can_refund?
    confirmed? && project.finished? && !project.successful? && project.expires_at.to_date + 120.days > DateTime.now
  end
  
  def can_use_credits?
    confirmed? && (not credits?) && project.finished? && !project.successful? && project.expires_at.to_date + 120.days > DateTime.now
  end

  def reward_must_be_from_project
    return unless reward
    errors.add(:reward, I18n.t('backer.reward_must_be_from_project')) unless reward.project == project
  end

  def value_must_be_at_least_rewards_value
    return unless reward
    errors.add(:value, I18n.t('backer.value_must_be_at_least_rewards_value', minimum_value: reward.display_minimum)) unless value >= reward.minimum_value
  end

  def should_not_back_if_maximum_backers_been_reached
    return unless reward and reward.maximum_backers and reward.maximum_backers > 0
    errors.add(:reward, I18n.t('backer.should_not_back_if_maximum_backers_been_reached')) unless reward.backers.confirmed.count < reward.maximum_backers
  end

  def project_should_be_online
    return if project && project.online?
    errors.add(:project, I18n.t('backer.project_should_be_online'))
  end

  def display_value
    number_to_currency value, unit: project.currency, precision: 0, delimiter: '.'
  end
  
  def display_value_usd
    number_to_currency (value / ::Configuration[:paypal_conversion].to_f).round(0), unit: "USD", precision: 0, delimiter: '.'
  end
  
  def available_rewards
    Reward.where(project_id: self.project_id).where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def display_confirmed_at
    I18n.l(confirmed_at.to_date) if confirmed_at
  end

  def as_json(options={})
    json_attributes = {
      id: id,
      anonymous: anonymous,
      confirmed: confirmed?,
      confirmed_at: display_confirmed_at,
      user: user.as_json(options.merge(anonymous: anonymous)),
      value: nil,
      display_value: nil,
      reward: nil
    }
    if options and options[:can_manage]
      json_attributes.merge!({
        value: display_value,
        display_value: display_value,
        reward: reward
      })
    end
    if options and options[:include_project]
      json_attributes.merge!({project: project})
    end
    if options and options[:include_reward]
      json_attributes.merge!({reward: reward})
    end
    json_attributes
  end

  state_machine :state, initial: :pending do
    state :pending, value: 'pending'
    state :waiting_confirmation, value: 'waiting_confirmation'
    state :confirmed, value: 'confirmed'
    state :canceled, value: 'canceled'
    state :refunded, value: 'refunded'
    state :requested_refund, value: 'requested_refund'
    state :refunded_and_canceled, value: 'refunded_and_canceled'
    state :deleted, value: 'deleted'
    state :denied, value: 'denied'
    
    event :push_to_trash do
      transition all => :deleted
    end

    event :pendent do
      transition all => :pending
    end

    event :waiting do
      transition pending: :waiting_confirmation
    end

    event :confirm do
      transition all => :confirmed
    end

    event :cancel do
      transition all => :canceled
    end

    event :request_refund do
      transition confirmed: :requested_refund
    end

    event :refund do
      transition [:requested_refund, :confirmed] => :refunded
    end

    event :hide do
      transition all => :refunded_and_canceled
    end
  
    event :deny do
      transition pending: :denied
    end
    
    after_transition confirmed: :requested_refund, do: :after_transition_from_confirmed_to_requested_refund
    after_transition confirmed: :canceled, do: :after_transition_from_confirmed_to_canceled
    after_transition any => :confirmed, :do => :after_transition_to_confirmed
  end

  def after_transition_to_confirmed
    unless self.matchfunding?
      self.project.channels.each do |channel|
        if channel.matchfunding_user.present? && channel.matchfunding_factor.present? && channel.matchfunding_factor > 0.0
          matchfunding_value = (self.value * channel.matchfunding_factor).round
          if channel.matchfunding_maximum && channel.matchfunding_maximum > 0.0 && (matchfunding_value + channel.matchfunding_total) > channel.matchfunding_maximum
            matchfunding_value = channel.matchfunding_maximum - channel.matchfunding_total
          end
          if channel.matchfunding_maximum_per_project && channel.matchfunding_maximum_per_project > 0.0 && (matchfunding_value + self.project.matchfunding_total(channel)) > channel.matchfunding_maximum_per_project
            matchfunding_value = channel.matchfunding_maximum_per_project - self.project.matchfunding_total(channel)
          end
          return unless matchfunding_value > 0.0
          if Backer.where(matchfunding_backer_id: self.id, matchfunding_channel_id: channel.id).empty?
            new_matchfunding_backer = self.project.backers.create user: channel.matchfunding_user, value: matchfunding_value, matchfunding: true, matchfunding_channel: channel, matchfunding_backer: self
            new_matchfunding_backer.confirm! unless new_matchfunding_backer.new_record?
          end
        end
      end
    end
  end

  def after_transition_from_confirmed_to_canceled
    notify_observers :notify_backoffice_about_canceled
  end

  def after_transition_from_confirmed_to_requested_refund
    notify_observers :notify_backoffice
  end

  # Used in payment engines
  def price_in_cents
    (self.value * 100).round
  end

  #==== Used on before and after callbacks

  def define_key
    self.update_attributes({ key: Digest::MD5.new.update("#{self.id}###{self.created_at}###{Kernel.rand}").to_s })
  end

  def define_payment_method
    self.update_attributes({ payment_method: 'PayULatam' })
  end

  def platform_fee
    self.value * self.project.actual_platform_fee
  end

  def subtotal
    self.value - self.platform_fee
  end

  def display_payment_method
    if self.credits?
      "Créditos"
    elsif self.user_id == 376
      "Gift Card"
    elsif self.payment_method == "Payroll"
      if self.payment_id =~ /gift/i
        "Gift Card"
      elsif self.payment_id =~ /otros/i
        "Otros"
      else
        "Libranza"
      end
    elsif self.payment_method == "LbmGiftCard"
      "#{self.payment_method}"
    else
      self.payment_method
    end
  end

  def display_code
    if self.payment_method == "LbmGiftCard"
      self.payment_id
    end
  end

  def conversion_fee
    return unless self.converted_value && self.converted_value > 0
    (self.value / self.converted_value).round(2)
  end

  def display_conversion_fee
    number_to_currency (self.conversion_fee), unit: "COP", precision: 2, delimiter: '.'
  end

  def display_converted_value
    number_to_currency self.converted_value, unit: self.converted_currency, precision: 2, delimiter: '.'
  end

  def paypal_fee
    return unless self.display_payment_method == "PayPal"
    self.payment_notifications.each do |notification|
      return notification.extra_data["fee_amount"].to_f if notification.extra_data["fee_amount"].present?
    end
    nil
  end

  def display_paypal_fee
    number_to_currency self.paypal_fee, unit: self.converted_currency, precision: 2, delimiter: '.'
  end

  def payulatam_fee
    return unless self.display_payment_method == "PayULatam"
    if self.created_at < Date.parse('01-05-2015')
      return 2750.0 if self.value < 37000.0
      self.value * 0.05 + 900.0
    else
      if self.value < 30000
        if self.payed_with == "PSE"
          return self.value * 0.06
        else
          return self.value * 0.06 + 500.0
        end
      else
        self.value * 0.0349 + 900.0
      end
    end
  end

  def g2c_fee(g2c_fee = ::Configuration[:g2c_fee].to_f)
    return unless self.converted_value && self.paypal_fee
    (g2c_fee * (self.converted_value - self.paypal_fee)).round(2)
  end

  def display_g2c_fee
    number_to_currency self.g2c_fee, unit: self.converted_currency, precision: 2, delimiter: '.'
  end

  def credits_fee
    return unless self.credits?
    (self.value * self.project.actual_credits_fee).round(2)
  end

  def total_fee(g2c_fee = ::Configuration[:g2c_fee].to_f)
    if self.display_payment_method == "PayPal"
      return unless self.paypal_fee && self.g2c_fee(g2c_fee) && self.conversion_fee
      ((self.paypal_fee + self.g2c_fee(g2c_fee)) * self.conversion_fee).round(2)
    elsif self.display_payment_method == "PayULatam"
      self.payulatam_fee
    elsif self.credits?
      self.credits_fee
    end
  end

  def payed_with
    if self.display_payment_method == "PayULatam"
      self.payment_notifications.each do |notification|
        return "Baloto" if notification.extra_data["payment_method"] == "35"
        return "PSE" if notification.extra_data["payment_method_name"] == "PSE"
        return notification.extra_data["franchise"] if notification.extra_data["franchise"].present?
      end
    end
    nil
  end

  def iva_payulatam_fee
    return unless self.payulatam_fee
    (self.payulatam_fee * 0.16).round(2)
  end

  def value_before_iva
    return unless self.display_payment_method == "PayULatam"
    (self.value / 1.16).round(2)
  end

  def iva
    return unless self.display_payment_method == "PayULatam"
    (self.value_before_iva * 0.16).round(2)
  end

  def renta_retention
    return unless self.display_payment_method == "PayULatam"
    if ["AMEX", "VISA", "MASTERCARD", "DINERS"].include?(self.payed_with)
      self.value * 0.015
    end
  end

  def ica_retention
    return unless self.display_payment_method == "PayULatam"
    if ["AMEX", "VISA", "MASTERCARD", "DINERS"].include?(self.payed_with)
      self.value * 0.00414
    end
  end

  def tax_refund
    return unless self.display_payment_method == "PayULatam"
    (self.renta_retention || 0) + (self.ica_retention || 0)
  end

  def value_reserve
    return unless self.display_payment_method == "PayULatam"
    self.value * 0.15
  end

  def reserve_plus_refund
    (self.tax_refund || 0) + (self.value_reserve || 0)
  end

  def total_costs(g2c_fee = ::Configuration[:g2c_fee].to_f)
    (self.total_fee(g2c_fee) || 0) + (self.iva_payulatam_fee || 0)
  end

  def net_platform_fee(g2c_fee = ::Configuration[:g2c_fee].to_f)
    self.platform_fee - self.total_costs(g2c_fee)
  end

  def payer_document
    self.user.cpf
  end

  def payer_name
    if self.display_payment_method == "PayULatam"
      self.payment_notifications.each do |notification|
        return notification.extra_data["cc_holder"] if notification.extra_data["cc_holder"].present?
      end
    end
    self.user.full_name || self.user.name
  end

  def payer_address
    if self.display_payment_method == "PayULatam"
      self.payment_notifications.each do |notification|
        return notification.extra_data["billing_address"] if notification.extra_data["billing_address"].present?
      end
    end
    self.user.address_street
  end

  def payer_city
    if self.display_payment_method == "PayULatam"
      self.payment_notifications.each do |notification|
        return notification.extra_data["billing_city"] if notification.extra_data["billing_city"].present?
      end
    end
    self.user.address_city
  end

  def payer_country
    self.user.address_zip_code
  end

  def payer_phone
    "#{self.user.address_complement} #{self.user.phone_number}".strip
  end

  def payer_email
    self.user.email
  end
  
  def terms_link
    project.channels.empty? ? I18n.t('footer.links.terms_link') : project.channels.first.default_terms_link
  end
  
  def self.total_backers
    Backer.pluck("COUNT(DISTINCT backers.user_id)")[0]
  end
  
  def self.total_backs_value
    Backer.pluck("SUM(value)")[0]
  end
  
  def self.average_back
    Backer.pluck("AVG(value)")[0]
  end
end
