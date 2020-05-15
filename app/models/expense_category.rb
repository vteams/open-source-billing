class ExpenseCategory < ApplicationRecord
  has_many :expenses, foreign_key: 'category_id'
end
