class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :template_type
      t.string :email_from
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
