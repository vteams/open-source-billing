class Expense < ActiveRecord::Base
  include DateFormats
  belongs_to :client
  belongs_to :category, class_name: 'ExpenseCategory', foreign_key: 'category_id'

  paginates_per 10

end
