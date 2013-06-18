class AddCompanyIdToSentEmails < ActiveRecord::Migration
  def change
    add_column :sent_emails, :company_id, :integer
  end
end
