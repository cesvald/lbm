class Channels::PhasesController < Channels::BaseController
    inherit_resources
    actions :create, :destroy
    
    def create
        #create! { root_url(subdomain: @channel.permalink, protocol: 'http') }
        create! { root_url }
    end
    
    def destroy
        #destroy! { root_url(subdomain: @channel.permalink, protocol: 'http') }
        destroy! { root_url }
    end
end