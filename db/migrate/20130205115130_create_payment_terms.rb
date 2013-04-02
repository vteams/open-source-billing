class CreatePaymentTerms < ActiveRecord::Migration
  def change
    create_table :payment_terms do |t|
      t.integer :number_of_days
      t.string :description

      t.timestamps
    end
    add_column :invoices, :payment_terms_id, :integer
  end
end
