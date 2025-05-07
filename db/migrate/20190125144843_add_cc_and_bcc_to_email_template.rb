class AddCcAndBccToEmailTemplate < ActiveRecord::Migration
  def change
    add_column :email_templates, :cc, :string
    add_column :email_templates, :bcc, :string
  end
end
