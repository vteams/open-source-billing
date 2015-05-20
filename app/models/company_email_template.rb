class CompanyEmailTemplate < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :email_template, :foreign_key => 'template_id'
end
