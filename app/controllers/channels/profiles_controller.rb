# -*- encoding : utf-8 -*-
class Channels::ProfilesController < Channels::BaseController
  inherit_resources
  defaults resource_class: Channel, finder: :find_by_permalink!
  actions :show
  custom_actions resource: [:how_it_works]

  #before_filter{ params[:id] = request.subdomain }
  before_filter{ params[:id] = 'clicsporsuenos' }
  def show
    #THIS LINE MUST BE REMOVED=================================
    
    show! do
      if @profile.group_channels.present?
        channel_ids = @profile.group_channels.map{|p| p.id }
        channel_ids << @profile.id
        @other_channels = Channel.other_channels(channel_ids)
      end
      @projects = @profile.projects.visible_or_draft
      @projects = @projects.visible unless @profile.show_drafts?
    end
  end

end
