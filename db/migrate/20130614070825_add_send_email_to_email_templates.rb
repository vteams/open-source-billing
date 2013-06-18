class AddSendEmailToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :send_email, :boolean, :default => true
    add_column :email_templates, :no_of_days, :integer
    add_column :email_templates, :is_late_payment_reminder, :boolean, :default => false
  end
end
