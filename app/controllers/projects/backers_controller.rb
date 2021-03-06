# -*- encoding : utf-8 -*-
class Projects::BackersController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :update_info, :review, :create
  skip_before_filter :force_http, only: [:update_info]
  skip_before_filter :verify_authenticity_token, only: [:moip]
  load_and_authorize_resource except: [:create]
  belongs_to :project

  skip_before_filter :verify_authenticity_token, only: [:create], if: -> { params[:access_token].present? }

  def update_info
    if !resource.pending?
      render json: {message: 'invalid'}
    else
      resource.update_attributes(params[:backer])
      render json: {message: 'updated'}
    end
  end

  def index
    if request.headers["HTTP_AUTHORIZATION"].present?
      return unless @api_authorized = authenticate_api(true)
    end
    @backers = parent.backers.available_to_count.order("confirmed_at DESC").page(params[:page]).per(10)
    render json: @backers.to_json(can_manage: (can?(:update, @project) || @api_authorized))
  end

  def show
    @title = t('projects.backers.show.title')
    session[:thank_you_backer_id] = nil
  end

  def new
    return redirect_to(action: 'new', protocol: 'http') if request.ssl?
    unless parent.online?
      flash[:failure] = t('projects.back.cannot_back')
      return redirect_to :root
    end
    
    @create_url = ::Configuration[:secure_review_host] ?
      project_backers_url(@project, {host: ::Configuration[:secure_review_host], protocol: 'https'}) :
      project_backers_path(@project)

    @title = t('projects.backers.new.title', name: @project.name)
    @backer = @project.backers.new(user: current_user)
    empty_reward = Reward.new(id: 0, minimum_value: 0, description: t('projects.backers.new.no_reward'))
    @rewards = [empty_reward] + @project.rewards.order(:minimum_value)
    @reward = @project.rewards.find params[:reward_id] if params[:reward_id]
    @reward = nil if @reward and @reward.sold_out?
    if @reward
      @backer.reward = @reward
      @backer.value = "%0.0f" % @reward.minimum_value
    end
    gon.paypal_conversion = ::Configuration[:paypal_conversion]
    gon.minimum_amount = @project.currency.minimum_amount.to_i
  end

  def create
    @title = t('projects.backers.create.title')
    @project = Project.find(params[:project_id])
    @backer = @project.backers.new(params[:backer])
    authenticate_token(params[:access_token]) if params[:access_token].present?
    authorize! :create, @backer
    @backer.reward_id = nil if params[:backer][:reward_id].to_s == '0'
    @backer.user = current_user
    create! do |success,failure|
      failure.html do
        flash[:failure] = t('projects.backers.review.error')
        return redirect_to new_project_backer_path(@project)
      end
      success.html do
        #require 'mercadopago.rb'
        #mp = MercadoPago.new(::Configuration[:mercadopago_id], ::Configuration[:mercadopago_secret])
        #preference_data = {"items": [{"title": t('projects.backers.checkout.mercadopago_description', project_name: @backer.project.name, value: @backer.display_value), "quantity": 1, "unit_price": @backer.value.to_f, "currency_id": "COP"}], "notification_url": mercadopago_notification_url, "back_urls": {"failure": mercadopago_failure_url, "pending": ::Configuration[:base_url], "success": mercadopago_success_url}, "additional_info": @backer.id}
        #@preference = mp.create_preference(preference_data)
        session[:thank_you_backer_id] = @backer.id
        return render :create
      end
    end
    @thank_you_id = @project.id
  end

  def credits_checkout
    if current_user.credits < @backer.value
      flash[:failure] = t('projects.backers.checkout.no_credits')
      return redirect_to new_project_backer_path(@backer.project)
    end

    unless @backer.confirmed?
      @backer.update_attributes({ payment_method: 'Credits' })
      @backer.confirm!
    end
    flash[:success] = t('projects.backers.checkout.success')
    redirect_to project_backer_path(project_id: parent.id, id: resource.id)
  end
end
