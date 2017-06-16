class Channels::IniciativesController < Channels::BaseController
    
    inherit_resources
    
    before_filter :find_financial_channel, only: [:new, :edit, :create, :show]
    
    def new
        iniciative = (current_user.nil? ? nil : Iniciative.where(contact_email: current_user.email).first)
        if iniciative.present?
            return redirect_to root_url, flash: { notice: I18n.t('iniciatives.new.email_exists') }
            #redirect_to root_url(subdomain: @financial_channel.channel.permalink)
        else
            gon.departments = departments
            new!
        end
    end
    
    def edit
        gon.departments = departments
        edit!
    end
    
    def create
        @iniciative = Iniciative.new(params[:iniciative])
        one_iniciative = Iniciative.where(contact_email: @iniciative.contact_email).first
        if one_iniciative.present?
            if @financial_channel.state == 'applying'
                flash[:failure] = I18n.t('iniciatives.create.fail.contact_email_exists_applying')
            else
                flash[:failure] = I18n.t('iniciatives.create.fail.contact_email_exists')
            end
            render :action => :new
        else
            create!(notice: t('iniciatives.create.success'), alert: t('iniciatives.create.failure')) do |success, failure|
              success.html{ return redirect_to root_url(subdomain: @financial_channel.channel.permalink) }
              #success.html{ return redirect_to root_url }
              failure.html{ return render :action => :new }
            end
        end
    end

    def add_vote
        iniiciative = Iniciative.find(params[:id])
        if iniiciative.already_voted?(current_user)
            flash[:failure] = 'Ya has realizado este voto, solo puedes votar una vez por proyecto'
        else
            iniiciative.add_vote
            iniiciative.votes.build(user: current_user)
            iniiciative.save
            flash[:success] = 'Has votado por este proyecto!!'
        end
            
        redirect_to :back
    end
    
    private
    
    def find_financial_channel
        #@financial_channel = FinancialChannel.joins(:channel).where("channels.permalink": request.subdomain).first
        @financial_channel = FinancialChannel.joins(:channel).where("channels.permalink": 'jovenesactivos').first
    end
    
end