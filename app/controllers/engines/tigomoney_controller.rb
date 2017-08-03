class Engines::TigomoneyController < Engines::BaseController
    layout :false
    
    SCOPE = "projects.backers.checkout"
    
    def review
        backer = current_user.backs.not_confirmed.find params[:id]
        if backer
            backer.update_attribute :payment_method, 'TigoMoney'
            if dev_environment? || test_environment?
                url = "https://securesandbox.tigo.com/v1/oauth/mfs/payments/tokens"
            else
                url = "https://prod.api.tigo.com/v1/oauth/mfs/payments/tokens"
            end
            headers_params = {"Content-Type" => "application/x-www-form-urlencoded", Authorization => "Basic #{Base64.strict_encode64([::Configuration[:tigo_public], ::Configuration[:tigo_private]].join(":"))}"}
            
            response = Typhoeus.post(url, body: "grant_type=client_credentials", headers: headers_params)
            @response = JSON.parse(response.body)
            if dev_environment? || test_environment?
                payment_url = "https://securesandbox.tigo.com/v2/tigo/mfs/payments/authorizations"
            else
                payment_url = "https://prod.api.tigo.com/v2/tigo/mfs/payments/authorizations"
            end
            @accesstoken = "Bearer " + Base64.strict_encode64("#{JSON.parse(response.body)["accessToken"]}")
            @respondUri = respond_engines_tigomoney_index_url
            payment_headers = { "Content-Type" => "application/json", Authorization => "Bearer #{JSON.parse(response.body)["accessToken"]}" }
            payment_params = {MasterMerchant: {account: "0985234111", pin: ::Configuration[:tigo_pin], id: "FundacionCapital"}, Subscriber: {account:"0981989591", countryCode: "595", country: "PRY", emailId: "jose.gomez@fundacioncapital.org"}, redirectUri: respond_engines_tigomoney_index_url , callbackUri: confirm_engines_tigomoney_index_url, language: "spa", OriginPayment:{amount: backer.value.to_s, currencyCode: "PYG", tax: "0.00", fee: "0..00"}, exchangeRate: "1", LocalPayment:{amount: backer.value.to_s, currencyCode: "PYG"}, merchantTransactionId: backer.id.to_s }
            payment_response = Typhoeus.post(payment_url, body: payment_params.to_json, headers: payment_headers)
            @payment_params = JSON.parse(payment_response.body)
            @payment_url = JSON.parse(payment_response.body)["redirectUrl"]
            
        end
    end
    
    def respond
        backer = Backer.find session[:thank_you_backer_id]
        backer.update_attribute :payment_method, 'Tigo Money'
        flash[:success] = t('success', scope: SCOPE)
        redirect_to project_backer_path(project_id: backer.project.id, id: backer.id)
    end
    
    def confirm
        puts "The backer id to process is " + params["merchantTransactionId"].to_s
        backer = Backer.find params["merchantTransactionId"]
        backer.payment_id = params["mfsTransactionId"]
        backer.payment_method = 'Tigo Money'
        backer.payment_choice = params["transactionDescription"]
        backer.save
        puts "Tigo Money confirmation for backer " + backer.id.to_s
        puts "Tigo Money response_code = " + params["transactionCode"]
        puts "Tigo Money response description = " + params["transactionDescription"]
        if params["transactionCode"] == "purchasepin-2016-0000-S"
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