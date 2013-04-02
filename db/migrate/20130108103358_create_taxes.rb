class CreateTaxes < ActiveRecord::Migration
  def change
    create_table :taxes do |t|
      t.string :name
      t.decimal :percentage

      t.timestamps
    end
  end
end
