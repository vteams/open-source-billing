class CreateSentEmails < ActiveRecord::Migration
  def change
    create_table :sent_emails do |t|
      t.date :date
      t.string :sender
      t.string :recipient
      t.string :type
      t.string :subject
      t.text :content
      t.timestamps
    end
  end
end
