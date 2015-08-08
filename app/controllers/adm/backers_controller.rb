class Adm::BackersController < Adm::BaseController
  menu I18n.t("adm.backers.index.menu", locale: :es) => Rails.application.routes.url_helpers.adm_backers_path(locale: :es)
  has_scope :by_id, :by_user_id, :by_key, :user_name_contains, :project_name_contains, :confirmed, :credits, :requested_refund, :refunded,
    :by_state, :by_payment_method, :by_value, :by_channel
  has_scope :between_values, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :between_confirmed_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :pending_to_refund do |controller, scope, value|
    if value.present?
      scope.pending_to_refund 
    else
      scope
    end
  end
  before_filter :set_title

  respond_to :xlsx, :only => :index

  def index
    index! do |format|
      format.html
      format.xlsx do
        @backers = end_of_association_chain.not_deleted.order("backers.created_at DESC")
      end
    end
  end

  def self.backer_actions
    %w[confirm pendent refund hide cancel push_to_trash].each do |action|
      define_method action do
        resource.send(action)
        flash[:notice] = I18n.t("adm.backers.messages.successful.#{action}")
        redirect_to adm_backers_path(params[:local_params])
      end
    end
  end
  backer_actions

  def change_reward
    resource.change_reward! params[:reward_id]
    flash[:notice] = I18n.t('adm.backers.messages.successful.change_reward')
    redirect_to adm_backers_path(params[:local_params])
  end

  protected
  def set_title
    @title = t("adm.backers.index.title")
  end

  def collection
    @backers ||= end_of_association_chain.not_deleted.order("backers.created_at DESC").page(params[:page])
  end
end
