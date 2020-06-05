class AddCcAndBccToEmailTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :email_templates, :cc, :string
    add_column :email_templates, :bcc, :string
  end
end
