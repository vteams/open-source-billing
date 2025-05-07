class ExpenseCategory < ActiveRecord::Base
  has_many :expenses, foreign_key: 'category_id'
end
