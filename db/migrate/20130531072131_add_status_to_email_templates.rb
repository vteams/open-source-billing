class AddStatusToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :status, :string
  end
end
