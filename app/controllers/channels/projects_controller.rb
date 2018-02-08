# -*- encoding : utf-8 -*-
class Channels::ProjectsController < ProjectsController
  
  belongs_to :channel, parent_class: Channel, finder: :find_by_permalink!, param: :profile_id
  
  custom_actions :resource => :delete, :collection => :search
  
  # Inheriting from the original Projects controller
  # With one addition: we include the project into the current channel
  before_filter only: [:create, :financial_create] {
    params[:project][:channels] = [parent]
    p "Here the point is the parent is "
    p parent.inspect
  }
  after_filter only: [:create, :financial_create] { notify_trustees }
  
  prepend_before_filter{ channel_permalink }
  
  def financial_new
    if parent.financial_channel.state != 'applying'
      return redirect_to root_url
    elsif !current_user and params[:iniciative_token].nil?
      @iniciative = nil
    else
      if current_user
        @iniciative = Iniciative.where(contact_email: current_user.email).first
      else
        @iniciative = Iniciative.find_by_token(:postulation, params[:iniciative_token])
      end
    end
    if @iniciative
      @project = Project.new
      @project.build_financial_project
    else
      redirect_to root_url, flash: { alert: I18n.t('channels.projects.new.alert_rights_financial') }
    end
  end
  
  def financial_create
    if params[:phone_number].empty?
      flash[:alert] = t('projects.create.phone_number_alert')
      @project = Project.new(params[:project])
      error = true
    end
    if params[:contact_name].empty?
      flash[:alert] = t('projects.create.contact_name_alert')
      @project = Project.new(params[:project])
      error = true
    end
    if not error and (not current_user) and params[:iniciative_token].present?
      user = User.where(email: params[:contact_email]).first
      unless user and Iniciative.find_by_token(:postulation, params[:iniciative_token]).present?
        temp_pass = Iniciative.generate_token(8)
        user = User.create(locale: I18n.locale, name: params[:contact_name], full_name: params[:contact_name], password: temp_pass, email: params[:contact_email], phone_number: params[:phone_number])
      end
    elsif not error and current_user
      current_user.phone_number = params[:phone_number]
      current_user.full_name = params[:contact_name]
      current_user.name = params[:contact_name]
      current_user.save
      user = current_user
    end
    if not error
      @project = user.projects.new(params[:project])
      error = (@project.save == false ? true : false)
      flash[:alert] = t('projects.create.alert') if error == true
    end
    if error
      render(action: :financial_new, namespace: :channels)
    else
      redirect_to project_by_slug_path(@project.permalink)
    end
  end
  
  def financial_update
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
      failure.html{
        render action: :financial_edit, namespace: :channels, flash: {alert: t('projects.update.error_alert')}
      }
    end
  end
  
  def financial_edit
    @project = Project.find(params[:id])
  end
  
  def finance
    @project = Project.find(params[:id])
    backer = Backer.create(user: current_user, project: @project, value: params[:value], financial: true)
    backer.confirm
    redirect_to @project
  end
  
  # After a project submission through a channel, notify all channel's trustees
  protected
    def notify_trustees

    end
    
    def channel_permalink
      if dev_environment? 
        params[:profile_id] = 'tonces'
      else
        params[:profile_id] = request.subdomain
      end
    
    end
end