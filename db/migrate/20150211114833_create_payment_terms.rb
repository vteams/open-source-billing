class CreatePaymentTerms < ActiveRecord::Migration
  def self.up
    unless table_exists? :payment_terms
      create_table :payment_terms do |t|
        t.integer  "number_of_days"
        t.string   "description"
        t.datetime "created_at",     null: false
        t.datetime "updated_at",     null: false
      end
    end
  end

  def self.down
    drop_table :payment_terms if table_exists? :payment_terms
  end
end
