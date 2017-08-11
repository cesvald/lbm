class Channels::Adm::IniciativesController < Adm::BaseController
    
    has_scope :by_channel, :by_name, :by_contact_email
	
	before_filter do
		if dev_environment?
    		@channel =  Channel.find_by_permalink!('tonces')
    	else
    		@channel =  Channel.find_by_permalink!(request.subdomain.to_s)
    	end
    end
    
	[:approve, :reject].each do |name|
			define_method name do
					@iniciative = Iniciative.find params[:id]
					@iniciative.send("#{name.to_s}!")
					redirect_to :back
			end
	end

	def index
		index! do |format|
			format.html do
				@channels = Channel.joins(:financial_channel)
			end
			format.xlsx do
				@iniciatives = end_of_association_chain.order("iniciatives.created_at DESC")
			end
		end
	end
	
	protected
		def begin_of_association_chain
	      @channel.financial_channel
	    end
	
	    def collection
	      @iniciatives = apply_scopes(@channel.financial_channel.iniciatives.order("iniciatives.created_at DESC").page(params[:page]))
	    end
end