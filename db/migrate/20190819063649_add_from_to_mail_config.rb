class AddFromToMailConfig < ActiveRecord::Migration
  def change
    add_column :mail_configs, :from, :string
  end
end
