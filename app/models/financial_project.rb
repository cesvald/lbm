class FinancialProject < ActiveRecord::Base
    
    belongs_to :project, dependent: :destroy
    belongs_to :postulation_category
    
    belongs_to :iniciative
    
    has_many :votes, dependent: :delete_all
    has_many :users, through: :votes
  
    validates_presence_of :benefited_count, :women_count, :department, :municipality, :organization_name, :hope_transform, :activities, :benefited_indirect_count, :convocation_description, :results_description, :budget
    
    mount_uploader :budget, DocumentUploader
    
    def add_vote
	  self.vote_count = self.vote_count + 1
	end
	
	def already_voted?(user)
	    users.exists?(user.id)
	end
	
end