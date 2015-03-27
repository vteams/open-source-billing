class CreateCompanyEmailTemplates < ActiveRecord::Migration
  def change
    create_table :company_email_templates do |t|
      t.integer  "template_id"
      t.integer  "parent_id"
      t.string   "parent_type"
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
    end
  end
end
