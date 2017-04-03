class RecurringProfileLineItem < ActiveRecord::Base
  # associations
  belongs_to :recurring_profile
  belongs_to :item
  belongs_to :tax1, :foreign_key => 'tax_1', :class_name => 'Tax'
  belongs_to :tax2, :foreign_key => 'tax_2', :class_name => 'Tax'
  attr_accessor :tax_one, :tax_two

  # archive and delete
  acts_as_archival
  acts_as_paranoid
end
