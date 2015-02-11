class CreatePaymentTerms < ActiveRecord::Migration
  def change
    create_table :payment_terms do |t|
      t.integer  "number_of_days"
      t.string   "description"
      t.datetime "created_at",     null: false
      t.datetime "updated_at",     null: false
    end
  end
end
