# -*- encoding : utf-8 -*-
class Channels::ProfilesController < Channels::BaseController
  inherit_resources
  defaults resource_class: Channel, finder: :find_by_permalink!
  actions :show, :create
  custom_actions resource: [:how_it_works]

  before_filter { channel_permalink }
  
  def show
    show! do
      if @profile.group_channels.present?
        channel_ids = @profile.group_channels.map{|p| p.id }
        channel_ids << @profile.id
        @other_channels = Channel.other_channels(channel_ids)
      end
      @projects = @profile.projects.visible_or_draft
      @projects = @projects.visible unless @profile.show_drafts?
      @phase = Phase.new
      if @profile.financial?
        @iniciatives = @profile.financial_channel.iniciatives.approved_or_confirmed
        gon.jbuilder template: 'app/views/channels/iniciatives/index.json'
      end
      
    end
  end
  
  def create
    create! do
      if params[:financial_channel] == "1"
        FinancialChannel.create(channel: @profile)
      end
    end
  end
  
  
  def channel_permalink
    redirect_to(protocol: 'http', host: ::Configuration[:base_domain], subdomain: request.subdomain) if request.ssl? if !dev_environment?

    if dev_environment?
      params[:id] = 'tonces'
    else
      params[:id] = request.subdomain
    end
  end
end