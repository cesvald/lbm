# -*- encoding : utf-8 -*-
class Channels::BaseController < ApplicationController
    before_filter :force_http
    
    private
    
    def force_http
        redirect_to(protocol: 'http', host: request.url ) if request.ssl?
    end
    
end
