# -*- encoding : utf-8 -*-
class SessionsController < Devise::SessionsController
    layout 'catarse_bootstrap'
    before_filter :force_https
    
    private
    
    def force_https
        if action_name == 'new' && !test_environment?
            redirect_to request.url.sub!('http', 'https') if not request.ssl?
        end
    end
end
