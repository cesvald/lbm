class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :code
      t.decimal :minimum_amount

      t.timestamps
    end
    
    Currency.create(code:'COP', minimum_amount: 25000)
    Currency.create(code:'PYG', minimum_amount: 45000)
  end
end
