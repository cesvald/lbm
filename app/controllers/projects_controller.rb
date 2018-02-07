# -*- encoding : utf-8 -*-
class ProjectsController < ApplicationController

  include ActionView::Helpers::DateHelper
  load_and_authorize_resource only: [ :create, :update, :destroy ]

  inherit_resources
  has_scope :pg_search, :by_category_id, :recent, :expiring, :successful, :partial_successful, :recommended, :not_expired, :near_of
  respond_to :html, except: [:backers]
  respond_to :json, only: [:index, :show, :backers, :update]
  skip_before_filter :detect_locale, only: [:backers]
  
  require 'rubygems'
  require 'zip'

  def index
    index! do |format|
      format.html do
        @title = t("site.title")

        #project_ids = collection_projects.map{|p| p.id }
        #project_ids << @recommended_projects.last.id if @recommended_projects

        #@projects_near = Project.online.near_of(current_user.address_state).order("random()").limit(3) if current_user
        #@channel = Channel.find_by_permalink("impacthub")
        #@channel_projects = @channel.projects.visible.order("random()").limit(3) if @channel
        
        @expiring = Project.expiring_for_home()
        #@expiring = Project.successful_for_home() if @expiring.empty? 
        @recent = Project.recent_for_home()
        @thereAreRecent = true
        if @recent.empty?
          project_ids = @expiring.map{|p| p.id }
          @recent = Project.successful_for_home_excluding(project_ids)
          @thereAreRecent = false
        end

        @categories = Category.with_projects.order("name_#{I18n.locale}").all

        @channels = Channel.visible
      end

      format.json do
        @projects = apply_scopes(Project).visible.order_for_search
        respond_with(@projects.includes(:project_total, :category).page(params[:page]).per(6))
      end
    end
  end

  def new
    new! do
      @title = t('projects.new.title')
      gon.partial_goal = ::Configuration[:partial_goal]
      @project.rewards.build
    end
  end

  def create
    if params[:phone_number].empty?
      flash[:alert] = I18n.t('projects.create.phone_number_alert')
      render action: :new
      return false
    else
      current_user.phone_number = params[:phone_number]
      current_user.save
    end
    @project = current_user.projects.new(params[:project])
    if @project.save
      redirect_to project_by_slug_path(@project.permalink)
    else
      params[:financial_project].present? ? render(action: :financial_new, namespace: :channels) : render(new_project_path)
    end
  end

  def update
    @project.updated_by = current_user
    update! do |success, failure|
      success.html{
        if @project.reviewed?
          flash[:notice] = I18n.t('projects.update.success_reviewed')
        else
          flash[:notice] = I18n.t('projects.update.success')
        end
        return redirect_to project_by_slug_path(@project.permalink)
      }
      success.json{
        if @project.identification_file.present? && @project.rut_file.present? && @project.comercial_file.present? && @project.bank_certificate_file.present? && @project.banking_data_file.present?
          @project.notify_admin_documents_ready
        end
        msg = { :url => @project.identification_file.url } if params[:project][:identification_file].present?
        msg = { :url => @project.rut_file.url } if params[:project][:rut_file].present?
        msg = { :url => @project.comercial_file.url } if params[:project][:comercial_file].present?
        msg = { :url => @project.bank_certificate_file.url } if params[:project][:bank_certificate_file].present?
        msg = { :url => @project.banking_data_file.url } if params[:project][:banking_data_file].present?
        render :json => msg
      }
      failure.html{
        return redirect_to project_by_slug_path(@project.permalink, anchor: 'edit')
      }
    end
  end

  def show
    begin
      if params[:permalink].present?
        @project = Project.not_deleted_projects.by_permalink(params[:permalink]).last
      else
        return redirect_to project_by_slug_path(resource.permalink)
      end
      
      if not dev_environment?
        if @project.financial?
          if !request.subdomain.present? || @project.financial_channel.channel.permalink != request.subdomain
            return redirect_to project_url(@project, subdomain: @project.financial_channel.channel.permalink, protocol: 'http')
          end
        end
      end
      
      show!{
        @title = @project.name
        @rewards = @project.rewards.order(:minimum_value).includes(:project).rank(:row_order).all
        @backers = @project.backers.confirmed.limit(12).order("confirmed_at DESC").all
        fb_admins_add(@project.user.facebook_id) if @project.user.facebook_id
        #TODO find a way to make accessible_by work here
        @updates = Array.new
        @project.updates.order('created_at DESC').each do |update|
          @updates << update if can? :see, update
        end
        @update = @project.updates.where(id: params[:update_id]).first if params[:update_id].present?
        @channel = Channel.find_by_permalink(request.subdomain) if request.subdomain.present?
        @pictures = @project.pictures
        @reward = params[:update_reward].present? ? Reward.find(params[:update_reward]) : nil
        if @project.financial?
          gon.is_financial_project = true
          gon.financial_project_edit_url = financial_edit_channels_project_url(@project)
        else
          gon.is_financial_project = false
        end
      }
    rescue ActiveRecord::RecordNotFound
      return render_404
    end
  end

  def video
    project = Project.new(video_url: params[:url])
    if project.video
      render json: project.video.to_json
    else
      render json: {video_id: false}.to_json
    end
  end

  def check_slug
    valid = false
    valid = true if !Project.permalink_on_routes?(params[:permalink]) && !Project.by_permalink(params[:permalink]).present?
    render json: {available: valid}.to_json
  end

  def embed
    @project = Project.find params[:id]
    @title = @project.name
    render layout: 'embed'
  end

  def video_embed
    @project = Project.find params[:id]
    @title = @project.name
    render layout: 'embed'
  end

  # Just to fix a minor bug,
  # when user submit the project without some rewards.
  def validate_rewards_attributes
    rewards = params[:project][:rewards_attributes]
    rewards.each do |r|
      rewards.delete(r[0]) unless Reward.new(r[1]).valid?
    end
  end

   def documents
    @project = Project.find params[:id]
    zip_dir = 'private/zip_files'
    zip_path = File.join(zip_dir, "#{@project.id}_#{Date.today.to_s}.zip")
    File.delete(zip_path) if File.exist?(zip_path)
    FileUtils.mkdir_p('private') unless File.directory?('private')
    FileUtils.mkdir_p('private/zip_files') unless File.directory?('private/zip_files')
    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      if @project.identification_file.present?
        zipfile.get_output_stream(@project.identification_file_identifier) { |os| os.write @project.identification_file.file.read }
      end
      if @project.rut_file.present?
        zipfile.get_output_stream(@project.rut_file_identifier) { |os| os.write @project.rut_file.file.read }
      end
      if @project.comercial_file.present?
        zipfile.get_output_stream(@project.comercial_file_identifier) { |os| os.write @project.comercial_file.file.read }
      end
      if @project.bank_certificate_file.present?
        zipfile.get_output_stream(@project.bank_certificate_file_identifier) { |os| os.write @project.bank_certificate_file.file.read }
      end
      if @project.banking_data_file.present?
        zipfile.get_output_stream(@project.banking_data_file_identifier) { |os| os.write @project.banking_data_file.file.read }
      end
    end
    File.open(zip_path, 'r') do |f|
      send_data f.read, type: "application/zip",  filename: "#{@project.name}.zip"
    end
    File.delete(zip_path)
  end

  protected

  def resource
    @project ||= Project.not_deleted_projects.find params[:id]
  end
end
