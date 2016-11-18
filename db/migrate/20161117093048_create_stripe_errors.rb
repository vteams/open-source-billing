class CreateStripeErrors < ActiveRecord::Migration
  def change
    create_table :stripe_errors do |t|
      t.string :email
      t.string :error_message
      t.string :error_code
      t.integer :user_id, index: true
      t.timestamps
    end
  end
end
