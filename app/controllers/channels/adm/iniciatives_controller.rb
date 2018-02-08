class Channels::Adm::IniciativesController < Adm::BaseController
		
		has_scope :by_channel, :by_name, :by_contact_email, :by_department, :by_municipality
	
	before_filter do
		if dev_environment?
			@channel =  Channel.find_by_permalink!('tonces')
		else
			@channel =  Channel.find_by_permalink!(request.subdomain.to_s)
		end
	end
		
	[:approve, :reject, :push_to_draft, :confirm].each do |name|
			define_method name do
					@iniciative = Iniciative.find params[:id]
					@iniciative.send("#{name.to_s}!")
					redirect_to :back
			end
	end
	
	def update
		if resource.municipality != params[:iniciative][:municipality] || resource.department != params[:iniciative][:department]
			params[:iniciative][:lat] = nil
			params[:iniciative][:lng] = nil
		end
		update!
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
	
	def edit
		edit! do |format|
			format.html do
				@financial_channel = @channel.financial_channel
			end
		end
	end
	
	def upload
		require 'csv'
		@user_response = ""
		excel = params[:file]
		puts 'INICIO ------------------------:   '
		CSV.foreach(excel.path, :headers => true, :col_sep => ';', encoding:'ISO-8859-1') do |row|
			iniciative = Iniciative.new()
			iniciative.name = row[0]
			if not row[0].nil?
				puts "Iniciativa con nombre: #{row[0]}"
				@user_response += "<b>#{row[0].rstrip.lstrip}: </b>"
				iniciative.remote_main_image_url = row["URLImagen"].rstrip.lstrip
				category_id = Category.where("lower(name_es) = ?", "#{row['Tipo'].downcase.rstrip.lstrip unless row['Tipo'].nil?}").pluck("id")
				if not category_id.any?
					puts "La categoría no existe"
					@user_response += "La categoría #{row["Tipo"]} no existe <br><br>"
				else
					puts "La categoría tiene el id " + category_id[0].to_s
					iniciative.category_id = category_id[0]
					iniciative.ethnic_count = row["NumEtnicos"].rstrip.lstrip if row["NumEtnicos"]
					iniciative.plurality = (row["Pluralidad"] == "Colectiva" ? "collective" : "individual")
					iniciative.ethnic_group = row["GrupoPoblacional"].rstrip.lstrip if row["GrupoPoblacional"]
					iniciative.description = row["Descripcion"]
					iniciative.year = row["Anio"].rstrip.lstrip if row["Anio"]
					iniciative.activities = row["Actividades"]
					iniciative.department = row["Departamento"].rstrip.lstrip if row["Departamento"]
					iniciative.municipality = row["Municipio"].rstrip.lstrip if row["Municipio"]
					iniciative.other_municipality = row["OtroMunicipio"].rstrip.lstrip if row["OtroMunicipio"]
					iniciative.participants_count = row["NumParticipantes"].rstrip.lstrip if row["NumParticipantes"]
					iniciative.zone = (row["RuralOUrbana"] == "Ambas" ? "both" : (row["RuralOUrbana"] == "Rural" ? "rural" : "urban"))
					iniciative.women_count = row["NumMujeres"].rstrip.lstrip if row["NumMujeres"]
					iniciative.average_age = row["PromedioEdad"].rstrip.lstrip if row["PromedioEdad"]
					iniciative.benefited_count = row["PersonasImpacto"].rstrip.lstrip if row["PersonasImpacto"]
					iniciative.web_url = row["PaginaWeb"].rstrip.lstrip if row["PaginaWeb"]
					iniciative.facebook_url = row["Facebook"].rstrip.lstrip if row["Facebook"]
					iniciative.blog_url = row["Blog"].rstrip.lstrip if row["Blog"]
					iniciative.video_url = row["URLVideo"].rstrip.lstrip if row["URLVideo"]
					iniciative.contact_name = row["NombreContacto"].rstrip.lstrip if row["NombreContacto"]
					iniciative.contact_email = row["CorreoContacto"].rstrip.lstrip if row["CorreoContacto"]
					iniciative.contact_phone = row["TelefonoContacto"].rstrip.lstrip if row["TelefonoContacto"]
					iniciative.state = (row["Estado"] == "Aprobada" ? "approved" : "rejected")
					iniciative.financial_channel_id = @channel.financial_channel.id
					iniciative.imported = true
					if iniciative.save
						puts "Iniciativa Guardada exitosamente"
						@user_response += "Iniciativa guardada exitosamente <br><br>"
					else
						puts "Hubo un problema con esta iniciativa: " + iniciative.errors.full_messages.inspect
						@user_response += "La iniciativa no se pudo guardar porque #{iniciative.errors.full_messages.inspect} <br><br>"
					end
					puts "Fin de iniciativa -----------------------"
				end
			end
		end
	end
	
	def update_upload
		require 'csv'
		excel = params[:file]
			puts 'INICIO ------------------------:   '
			CSV.foreach(excel.path, :headers => true, :col_sep => ';', encoding:'ISO-8859-1') do |row|
			@iniciative = Iniciative.where(name: row[0]).first
			if @iniciative
				puts 'Iniciativa con nombre: ' + row[0] + ' encontrada'
				
				@iniciative.ethnic_count = row["NumEtnicos"] if row["NumEtnicos"]
				@iniciative.ethnic_group = row["GrupoPoblacional"] if row["NumEtnicos"]
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
					puts "Iniciativa Actualizada exitosamente"
				else
					puts "Hubo un problema con esta iniciativa: " + @iniciative.errors.full_messages.inspect
				end
			else
				puts "Iniciaiva con nombre " + row[0] + " no existe"
			end
			puts "Fin de iniciativa -----------------------"
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