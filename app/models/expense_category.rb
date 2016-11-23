class ExpenseCategory < ActiveRecord::Base
  include Osbm
  has_many :expenses, foreign_key: 'category_id'
end
