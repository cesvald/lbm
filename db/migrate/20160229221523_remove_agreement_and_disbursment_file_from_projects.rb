class RemoveAgreementAndDisbursmentFileFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :agreement_file
    remove_column :projects, :disbursement_request_file
  end

  def down
    add_column :projects, :disbursement_request_file, :string
    add_column :projects, :agreement_file, :string
  end
end
