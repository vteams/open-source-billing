class AddFromToMailConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :mail_configs, :from, :string
  end
end
