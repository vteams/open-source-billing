class CreateCompanyEmailTemplates < ActiveRecord::Migration
  def change
    create_table :company_email_templates do |t|
      t.integer :template_id
      t.integer :parent_id
      t.string :parent_type

      t.timestamps
    end
  end
end
