# -*- encoding : utf-8 -*-
class Channels::ProjectsController < ProjectsController
  
  belongs_to :channel, parent_class: Channel, finder: :find_by_permalink!, param: :profile_id
  
  # Inheriting from the original Projects controller
  # With one addition: we include the project into the current channel
  before_filter only: [:create, :financial_create] {
    params[:project][:channels] = [parent]
    p "Here the point is the parent is "
    p parent.inspect
  }
  after_filter only: [:create, :financial_create] { notify_trustees }
  
  before_filter only: [:financial_new, :financial_edit, :financial_create, :financial_update] {
    if not parent.financial_channel.applying?
      flash[:alert] = t('financial_projects.closed')
      return redirect_to root_url
    end
  }
  
  prepend_before_filter{ channel_permalink }
  
  def financial_new
    @channel = parent
    @project = Project.new
    @project.build_financial_project
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
    if params[:contact_email].empty?
      flash[:alert] = t('projects.create.contact_email_alert')
      @project = Project.new(params[:project])
      error = true
    end
    if not error
      user = User.where(email: params[:contact_email]).first
      unless user
        temp_pass = Iniciative.generate_token(8)
        user = User.create(locale: I18n.locale, name: params[:contact_name], full_name: params[:contact_name], password: temp_pass, email: params[:contact_email], phone_number: params[:phone_number])
      end
      user.phone_number = params[:phone_number]
      user.full_name = params[:contact_name]
      user.name = params[:contact_name]
      user.save
    end
    if not error
      iniciative = Iniciative.where(contact_email: user.email).first
      if iniciative.nil?
        flash[:alert] = "No existe ninguna iniciativa con el email #{params[:contact_email]}"
        @project = Project.new(params[:project])
        error = true
      else
        @project = user.projects.new(params[:project])
        @project.financial_project.iniciative = iniciative
        error = (@project.save == false ? true : false)
        flash[:alert] = t('projects.create.alert') if error == true
      end
    end
    if error
      render(action: :financial_new, namespace: :channels)
    else
      flash[:notice] = t('projects.create.success')
      redirect_to project_by_slug_path(@project.permalink)
    end
  end
  
  def financial_update
    @project = resource
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
        flash[:alert] = t('projects.update.alert')
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