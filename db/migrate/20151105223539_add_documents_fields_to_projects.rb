class AddDocumentsFieldsToProjects < ActiveRecord::Migration
  def change
  	add_column :projects, :identification_file, :string
  	add_column :projects, :rut_file, :string
  	add_column :projects, :comercial_file, :string
  	add_column :projects, :bank_certificate_file, :string
  	add_column :projects, :agreement_file, :string
  	add_column :projects, :disbursement_request_file, :string
  end
end
