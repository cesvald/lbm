class FinancialProject < ActiveRecord::Base
    belongs_to :project
    validates_presence_of :benefited_count, :women_count, :department, :municipality, :zone
end