class CreateIntroductions < ActiveRecord::Migration
  def change
    create_table :introductions do |t|
      t.boolean :dashboard, default: false
      t.boolean :invoice, default: false
      t.boolean :new_invoice, default: false
      t.boolean :estimate, default: false
      t.boolean :new_estimate, default: false
      t.boolean :payment, default: false
      t.boolean :new_payment, default: false
      t.boolean :client, default: false
      t.boolean :new_client, default: false
      t.boolean :item, default: false
      t.boolean :new_item, default: false
      t.boolean :tax, default: false
      t.boolean :new_tax, default: false
      t.boolean :report, default: false
      t.boolean :setting, default: false
      t.boolean :invoice_table, default: false
      t.boolean :estimate_table, default: false
      t.boolean :payment_table, default: false
      t.boolean :client_table, default: false
      t.boolean :item_table, default: false
      t.boolean :tax_table, default: false
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    User.all.each do |u|
      intro = Introduction.new
        intro.user_id = u.id
        intro.save
    end
  end
end
