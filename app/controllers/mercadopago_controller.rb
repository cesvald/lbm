class MercadopagoController < ApplicationController
    def notification
        render status: 400, nothing: true
    end

    def confirm
        backer = Backer.find params[:id]
        if proccess_mercadopago_response(backer, params)
          render status: 200, nothing: true
        else
          render status: 422, nothing: true
        end
      rescue Exception => e
        Rails.logger.info "mercadopago Confirmation Error -----> #{e.inspect}"
        render status: 500, nothing: true
    end
    
    def success
            
    end
    
  protected

  def proccess_mercadopago_response(backer, params)
    PaymentEngines.create_payment_notification backer_id: backer.id, extra_data: params
    
    backer.update_attribute :payment_id, mercadopago_response.transaction_id
    if mercadopago_response.success?
      backer.confirm!  
    elsif mercadopago_response.failure?
      backer.pendent!
    else
      backer.waiting! if backer.pending?
    end
    true
  end
end
