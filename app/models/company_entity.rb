class CompanyEntity < ApplicationRecord
  belongs_to :entity, :polymorphic => true
  belongs_to :parent, :polymorphic => true

  scope :company_ids, -> (entity_id, entity_type) { where(entity_id: entity_id, entity_type: entity_type).pluck(:parent_id) }
end
