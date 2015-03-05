class CreateCompanyEmailTemplates < ActiveRecord::Migration
  def self.up
    unless table_exists? :company_email_templates
      create_table :company_email_templates do |t|
        t.integer  "template_id"
        t.integer  "parent_id"
        t.string   "parent_type"
        t.datetime "created_at",  null: false
        t.datetime "updated_at",  null: false
      end
    end
  end

  def self.down
    drop_table :company_email_templates if table_exists? :company_email_templates
  end
end
