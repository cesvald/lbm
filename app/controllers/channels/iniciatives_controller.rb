class Channels::IniciativesController < Channels::BaseController
    
    inherit_resources
    
    before_filter :find_financial_channel, only: [:new, :edit, :create, :show]
    
    def new
        return redirect_to root_url if @financial_channel.state != 'summoning'
        gon.departments = departments
        new!
    end
    
    def edit
        gon.departments = departments
        edit!
    end
    
    def create
        @iniciative = Iniciative.new(params[:iniciative])

        create!(notice: t('iniciatives.create.success')) do |success, failure|
          #success.html{ return redirect_to root_url(subdomain: @financial_channel.channel.permalink) }
          success.html{ return redirect_to root_url }
          #failure.html{ return redirect_to not_exist_path }
        end
    end

    
    private
    
    def find_financial_channel
        #@financial_channel = FinancialChannel.joins(:channel).where("channels.permalink": request.subdomain).first
        @financial_channel = FinancialChannel.joins(:channel).where("channels.permalink": 'jovenesactivos').first
    end
    
end