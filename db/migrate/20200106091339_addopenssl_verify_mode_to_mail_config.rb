class AddopensslVerifyModeToMailConfig < ActiveRecord::Migration
  def change
    add_column :mail_configs, :openssl_verify_mode, :string
  end
end
