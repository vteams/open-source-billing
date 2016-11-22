class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :plan, index: true
      t.string :full_name
      t.string :company
      t.string :email
      t.string :card_token
      t.date :end_date
      t.string :customer_id
      t.string :subscription_id
      t.string :status
      t.timestamps
    end
  end
end
