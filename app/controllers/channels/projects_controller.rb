# -*- encoding : utf-8 -*-
class Channels::ProjectsController < ProjectsController
  
  belongs_to :channel, parent_class: Channel, finder: :find_by_permalink!, param: :profile_id


  # Inheriting from the original Projects controller
  # With one addition: we include the project into the current channel
  before_filter only: [:create] { params[:project][:channels] = [@channel] }
  after_filter only: [:create] { notify_trustees }
  
  #prepend_before_filter{ params[:profile_id] = request.subdomain }
  #prepend_before_filter{ params[:profile_id] = 'clicsporibague' }
  prepend_before_filter{ params[:profile_id] = 'jovenesactivos' }

  def new
    if parent.financial? and parent.financial_channel.state != 'applying'
      return redirect_to root_url
    end
    
    if parent.financial? and !current_user
      return redirect_to root_url, flash: { notice: t('projects.new.access_financial') }
    elsif parent.financial? and current_user
      @iniciative = parent.financial_channel.iniciatives.where(contact_email: current_user.email).first
      if not @iniciative.present?
        return redirect_to root_url, flash: { notice: "No existe una iniciativa creada con tu usuario. Por favor envía una iniciativa antes de crear el proyecto."}
      elsif @iniciative.draft?
        return redirect_to root_url, flash: { notice: "Tu iniciativa no ha sido aprobada aún. Si deseas escríbenos a littlebigmoney@fundacioncapital.org y en breve te daremos una respuesta"}
      end
    end
    super
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
end