class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_name
      t.string :item_description
      t.decimal :unit_cost
      t.decimal :quantity
      t.integer :tax_1
      t.integer :tax_2
      t.boolean :track_inventory
      t.integer :inventory
      t.string :archive_number
      t.datetime :archived_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
