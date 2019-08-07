class Permission < ActiveRecord::Base
  belongs_to :role

  # ENTITY_TYPES = %W(Invoice Estimate Payment)
end
