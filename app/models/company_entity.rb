class CompanyEntity < ApplicationRecord
  belongs_to :entity, :polymorphic => true
  belongs_to :parent, :polymorphic => true
end
