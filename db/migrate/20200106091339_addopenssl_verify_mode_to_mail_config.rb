class AddopensslVerifyModeToMailConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :mail_configs, :openssl_verify_mode, :string
  end
end
