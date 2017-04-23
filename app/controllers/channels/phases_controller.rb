class Channels::PhasesController < Channels::BaseController
    inherit_resources
    actions :create, :destroy
    
    def create
        @channel = Channel.find(params[:phase][:channel_id])
        create! { root_url(subdomain: @channel.permalink, protocol: 'http') }
        #create! { root_url }
    end
    
    def destroy
        destroy! { root_url(subdomain: resource.financial_channel.channel.permalink, protocol: 'http') }
        #destroy! { root_url }
    end
end