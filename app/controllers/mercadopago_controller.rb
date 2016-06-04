class MercadopagoController < ApplicationController
  SCOPE = "projects.backers.checkout"
  def success
      begin
        if proccess_mercadopago_response(params)
          flash[:success] = t('success', scope: SCOPE)
          redirect_to main_app.project_backer_path(project_id: @backer.project.id, id: @backer.id)
        else
          flash[:failure] = t('mercadopago_error', scope: SCOPE)
          return redirect_to ::Configuration[:base_url]
        end
      rescue Exception => e
        Rails.logger.info "mercadopago Response Error -----> #{e.inspect}"
        flash[:failure] = t('mercadopago_error', scope: SCOPE)
        return redirect_to ::Configuration[:base_url]
      end
  end

  def failure
    flash[:failure] = t('mercadopago_error', scope: SCOPE)
    return redirect_to ::Configuration[:base_url]
  end
  
  def notification
    if proccess_mercadopago_response(params)
      render status: 200, nothing: true
    else
      render status: 422, nothing: true
    end
  rescue Exception => e
    Rails.logger.info "mercadopago Confirmation Error -----> #{e.inspect}"
    render status: 500, nothing: true
  end

  protected

  def proccess_mercadopago_response(params)
    require 'mercadopago.rb'
    mp = MercadoPago.new(::Configuration[:mercadopago_id_test], ::Configuration[:mercadopago_secret_test])
    merchant_order_info = nil
    if params[:topic] == 'merchant_order'
      merchant_order_info = mp.get("/merchant_orders/" + params[:id])
    elsif params[:topic] == 'payment'
      payment_info = mp.get("/collections/notifications/" + params[:id])
      merchant_order_info = mp.get("/merchant_orders/" + payment_info["response"]["collection"]["merchant_order_id"])
    elsif params[:merchant_order_id].present?
      merchant_order_info = mp.get("/merchant_orders/" + params[:merchant_order_id])
    end
    
    return false if merchant_order_info.nil?
    
    #if merchant_order_info["status"] == "200" && merchant_order_info["response"]["status"] == "closed"
    p merchant_order_info
    @backer = Backer.find(merchant_order_info["response"]["additional_info"])
    @backer.update_attributes(payment_id: merchant_order_info["response"]["payments"][0][:id], payment_method: "mercadopago")
    PaymentEngines.create_payment_notification backer_id: @backer.id, extra_data: params
    payment_status = merchant_order_info["response"]["payments"][0]["status"]
    case payment_status
    when "approved"
      @backer.confirm!
    when "cancelled"
      @backer.cancel!
    when "pending"
      @backer.pendent!
    when "in_process"
      @backer.waiting!
    end
    #end
    
    true
    
    #backer.update_attribute :payment_id, params[].transaction_id
    #if mercadopago_response.success?
    #  backer.confirm!  
    #elsif mercadopago_response.failure?
    #  backer.pendent!
    #else
    #  backer.waiting! if backer.pending?
    #end
    #true
  end
end
