class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string   "template_type"
      t.string   "email_from"
      t.string   "subject"
      t.text     "body"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.string   "status"
      t.integer  "torder"
      t.boolean  "send_email",               default: true
      t.integer  "no_of_days"
      t.boolean  "is_late_payment_reminder", default: false
    end
  end
end
