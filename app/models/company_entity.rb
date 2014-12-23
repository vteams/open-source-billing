class CompanyEntity < ActiveRecord::Base
  #attr_accessible :entity_id, :entity_type, :parent_id, :parent_type

  belongs_to :entity, :polymorphic => true
  belongs_to :parent, :polymorphic => true
end
