class CreateMailConfigs < ActiveRecord::Migration
  def change
    create_table :mail_configs do |t|
      t.string :address
      t.integer :port
      t.string :authentication
      t.string :user_name
      t.string :password
      t.boolean :enable_starttls_auto
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
