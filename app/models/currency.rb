class Currency < ActiveRecord::Base
	include ActionView::Helpers::NumberHelper
  
	attr_accessible :code, :minimum_amount
	
	def display_minimum_amount
		number_to_currency minimum_amount, unit: code, precision: 0, delimiter: '.'
	end
	
	def to_s
			code
	end
end
