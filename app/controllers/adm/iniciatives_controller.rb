class Adm::IniciativesController < Adm::BaseController
		
		has_scope :by_channel, :by_name, :by_contact_email, :by_department, :by_municipality
		
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
		
		def collection
				@iniciatives = end_of_association_chain.order("iniciatives.created_at DESC").page(params[:page])
		end
end