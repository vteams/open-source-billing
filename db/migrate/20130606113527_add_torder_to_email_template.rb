class AddTorderToEmailTemplate < ActiveRecord::Migration
  def change
    add_column :email_templates, :torder, :integer
  end
end
