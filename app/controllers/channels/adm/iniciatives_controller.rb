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
	
	def upload
		require 'csv'
		excel = params[:file]
			puts 'INICIO ------------------------:   '
			CSV.foreach(excel.path, :headers => true, :col_sep => ';', encoding:'ISO-8859-1') do |row|
			@iniciative = Iniciative.new()
			@iniciative.name = row[0]
			puts 'Iniciativa con nombre: ' + row[0]
			@iniciative.remote_main_image_url = row["URLImagen"]
			category_id = Category.where(name_es: row["Tipo"]).pluck("id")
			if not category_id.any?
				puts "La categoría no existe"
			else
				puts "La categoría tiene el id " + category_id[0].to_s
				@iniciative.category_id = category_id[0]
				@iniciative.ethnic_count = row["NumEtnicos"]
				@iniciative.plurality = (row["Pluralidad"] == "Colectiva" ? "collective" : "individual")
				@iniciative.ethnic_group = row["GrupoPoblacional"]
				@iniciative.description = row["Descripcion"]
				@iniciative.year = row["Anio"]
				@iniciative.activities = row["Actividades"]
				@iniciative.department = row["Departamento"]
				@iniciative.municipality = row["Municipio"]
				@iniciative.other_municipality = row["OtroMunicipio"]
				@iniciative.participants_count = row["NumParticipantes"]
				@iniciative.zone = (row["RuralOUrbana"] == "Ambas" ? "both" : (row["RuralOUrbana"] == "Rural" ? "rural" : "urban"))
				@iniciative.women_count = row["NumMujeres"]
				@iniciative.average_age = row["PromedioEdad"]
				@iniciative.benefited_count = row["PersonasImpacto"]
				@iniciative.web_url = row["PaginaWeb"]
				@iniciative.facebook_url = row["Facebook"]
				@iniciative.blog_url = row["Blog"]
				@iniciative.video_url = row["URLVideo"]
				@iniciative.contact_name = row["NombreContacto"]
				@iniciative.contact_email = row["CorreoContacto"]
				@iniciative.contact_phone = row["TelefonoContacto"]
				@iniciative.state = (row["Estado"] == "Aprobada" ? "approved" : "rejected")
				@iniciative.financial_channel_id = @channel.financial_channel.id
				@iniciative.imported = true
				if @iniciative.save
					puts "Iniciativa Guardada exitosamente"
				else
					puts "Hubo un problema con esta iniciativa: " + @iniciative.errors.full_messages.inspect
				end
				puts "Fin de iniciativa -----------------------"
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