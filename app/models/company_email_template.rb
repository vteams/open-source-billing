class CompanyEmailTemplate < ActiveRecord::Base
  #attr_accessible :parent_id, :parent_type, :template_id

  belongs_to :parent, :polymorphic => true
  belongs_to :email_template, :foreign_key => 'template_id'
end
