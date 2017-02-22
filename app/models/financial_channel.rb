class FinancialChannel < ActiveRecord::Base
    belongs_to :channel
    has_many :phases
end