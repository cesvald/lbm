class Channels::IniciativesController < Channels::BaseController
    
    inherit_resources
    
    before_filter :find_financial_channel, only: [:new]
    
    def new
        gon.departments = departments
        new!
    end
    
    def edit
        gon.departments = departments
        edit!
    end
    
    def find_financial_channel
        #@financial_channel = FinancialChannel.joins(:channel).where("channels.permalink": request.subdomain).first
        @financial_channel = FinancialChannel.joins(:channel).where("channels.permalink": 'jovenesactivos').first
    end
    
end