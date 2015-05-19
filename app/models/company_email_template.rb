class CompanyEmailTemplate < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :email_template, :foreign_key => 'template_id'

  after_save do
    if self.parent_type == 'Account'
      self.update_column(:parent_id, self.account_id)
    end
  end

end
