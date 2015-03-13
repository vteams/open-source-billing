class CompanyEntity < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  belongs_to :parent, :polymorphic => true
end
