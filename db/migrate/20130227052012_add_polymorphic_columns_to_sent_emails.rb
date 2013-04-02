class AddPolymorphicColumnsToSentEmails < ActiveRecord::Migration
  def change
    add_column :sent_emails, :notification_id, :integer
    add_column :sent_emails, :notification_type, :string
  end
end
