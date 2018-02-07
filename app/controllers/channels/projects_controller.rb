# -*- encoding : utf-8 -*-
class Channels::ProjectsController < ProjectsController
  
  
  belongs_to :channel, parent_class: Channel, finder: :find_by_permalink!, param: :profile_id
  
  # Inheriting from the original Projects controller
  # With one addition: we include the project into the current channel
  before_filter only: [:create] { params[:project][:channels] = [@channel] }
  after_filter only: [:create] { notify_trustees }
  
  prepend_before_filter{ channel_permalink }
  
  
  def financial_new
    if parent.financial? and parent.financial_channel.state != 'applying'
      return redirect_to root_url
    elsif parent.financial? and !current_user
      if params[:user][:email].present?
        if User.where(email: params[:user][:email]).first
          redirect_to new_user_session_path, flash: { notice: 'Inicia sesión para poder enviar tu proyecto' }
        elsif (iniciative = Iniciative.where(contact_email: params[:user][:email]).first)
          redirect_to new_user_registration_path("user[email]": params[:user][:email], "user[name]": iniciative.contact_name), flash: { notice: 'Regístrate para poder enviar tu proyecto' }
        else
          return redirect_to root_url, flash: { notice: t('channels.projects.new.alert_access_financial') }
        end
      end
    else
      @iniciative = Iniciative.where(contact_email: current_user.email).first
      @project = Project.new
      @project.build_financial_project
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