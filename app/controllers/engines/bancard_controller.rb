class Engines::BancardController < Engines::BaseController
    layout :false
    
    SCOPE = "projects.backers.checkout"
    
    def review
        backer = current_user.backs.not_confirmed.find params[:id]
        if backer
            backer.update_attribute :payment_method, 'Bancard'
            Bancard.sandbox!
            gateway = Bancard::Gateway.new(public_key: ::Configuration[:bancard_public], private_key: ::Configuration[:bancard_private])
            buyResponse = gateway.single_buy({
                shop_process_id: backer.id,
                amount_in_cents: backer.value * 100,
                description: t('bancard_description', scope: SCOPE, :project_name => backer.project.name),
                return_url: respond_engines_bancard_url(backer),
                cancel_url: cancel_engines_bancard_url(backer)
            })
            
            @payment_url = buyResponse.payment_url
            @request_params = gateway.public_key
            @original_response = buyResponse.params
        end
    end
    
    def rollback
        Bancard.sandbox!
        gateway = Bancard::Gateway.new(public_key: ::Configuration[:bancard_public], private_key: ::Configuration[:bancard_private])
        rollbackResponse = gateway.rollback({
            shop_process_id: params[:id]
        })
        
        @rollback_params = rollbackResponse.params
    end
    
    def confirmation
        Bancard.sandbox!
        gateway = Bancard::Gateway.new(public_key: ::Configuration[:bancard_public], private_key: ::Configuration[:bancard_private])
        confirmationResponse = gateway.confirmation({
            shop_process_id: params[:id]
        })
        
        @confirmation_params = confirmationResponse.params
    end
    
    def cancel
        backer = Backer.find params[:id]
        backer.update_attribute :payment_method, 'Bancard'
        backer.cancel!
        redirect_to new_project_backer_path(backer.project)
    end
    
    def respond
        backer = Backer.find params[:id]
        backer.update_attribute :payment_method, 'Bancard'
        flash[:success] = t('success', scope: SCOPE)
        redirect_to project_backer_path(project_id: backer.project.id, id: backer.id)
    end
    
    def confirm
        puts "The backer id to process is " + params["operation"]["shop_process_id"].to_s
        backer = Backer.find params["operation"]["shop_process_id"]
        backer.update_attribute :payment_id, params["operation"]["ticket_number"].to_s
        backer.update_attribute :payment_method, 'Bancard'
        puts "Bancard confirmation for backer " + backer.id.to_s
        puts "Bancard response_code = " + params["operation"]["response_code"]
        puts "Bancard response description = " + params["operation"]["response_description"]
        if params["operation"]["response_code"] == "00"
            backer.confirm!
        else
            backer.deny!
        end
        render json: {success: true}
    rescue Exception => e
        Rails.logger.info "Bancard Confirmation Error -----> #{e.inspect}"
        render json: {success: true}
    end
end