class AddtlsToMailConfig < ActiveRecord::Migration
  def change
    add_column :mail_configs, :tls, :boolean, default: true
  end
end
