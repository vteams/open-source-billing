class AddtlsToMailConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :mail_configs, :tls, :boolean, default: true
  end
end
