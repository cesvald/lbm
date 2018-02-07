class FinancialProject < ActiveRecord::Base
    
    belongs_to :project
    belongs_to :postulation_category
     
    validates_presence_of :benefited_count, :women_count, :department, :municipality, :organization_name, :hope_transform, :activities, :benefited_indirect_count, :convocation_description, :results_description, :budget
    
    mount_uploader :budget, DocumentUploader
end