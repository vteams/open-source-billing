class RecurringProfileLineItem < ActiveRecord::Base
  #attr
  attr_accessible :recurring_profile_id, :item_id, :item_name, :item_description, :item_unit_cost, :item_quantity, :tax_1, :tax_2, :created_at, :updated_at, :archive_number, :archived_at, :deleted_at

  # associations
  belongs_to :recurring_profile
  belongs_to :item
  belongs_to :tax1, :foreign_key => 'tax_1', :class_name => 'Tax'
  belongs_to :tax2, :foreign_key => 'tax_2', :class_name => 'Tax'

  # archive and delete
  acts_as_archival
  acts_as_paranoid
end
