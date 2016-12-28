# -*- encoding : utf-8 -*-
class Channels::ProjectsController < ProjectsController
  #belongs_to :channel, finder: :find_by_permalink!, param: :profile_id


  # Inheriting from the original Projects controller
  # With one addition: we include the project into the current channel
  #before_filter only: [:create] { params[:project][:channels] = [@channel] }
  after_filter only: [:create] { notify_trustees }
  before_filter :force_http
  
  prepend_before_filter{ params[:profile_id] = request.subdomain }
  #prepend_before_filter{ params[:profile_id] = 'clicsporsuenos' }



  # After a project submission through a channel, notify all channel's trustees
  protected
    def notify_trustees

    end
  private
    def force_http
        redirect_to(protocol: 'http', host:"#{request.subdomain}.#{::Configuration[:base_domain]}")
    end
end