class CreateSentEmails < ActiveRecord::Migration
  def self.up
    unless table_exists? :sent_emails
      create_table :sent_emails do |t|
        t.date     "date"
        t.string   "sender"
        t.string   "recipient"
        t.string   "type"
        t.string   "subject"
        t.text     "content"
        t.datetime "created_at",        null: false
        t.datetime "updated_at",        null: false
        t.integer  "notification_id"
        t.string   "notification_type"
        t.integer  "company_id"
      end
    end
  end

  def self.down
    drop_table :sent_emails if table_exists? :sent_emails
  end
end
