# -*- encoding : utf-8 -*-
class Channels::Adm::BackersController < Adm::BackersController
  before_filter do
    if dev_environment?
      @channel =  Channel.find_by_permalink!('ligas')
    else
      @channel =  Channel.find_by_permalink!(request.subdomain.to_s)
    end
  end
  
  protected
    def collection
        @backers ||= apply_scopes(Backer.joins(project: [:channels]).not_deleted.where('channels.id = ?', @channel.id).order("backers.created_at DESC").page(params[:page]))
    end
end
