class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string   "item_name"
      t.string   "item_description"
      t.decimal  "unit_cost",        precision: 10, scale: 2
      t.decimal  "quantity",         precision: 10, scale: 2
      t.integer  "tax_1"
      t.integer  "tax_2"
      t.boolean  "track_inventory"
      t.integer  "inventory"
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.datetime "created_at",                                              null: false
      t.datetime "updated_at",                                              null: false
      t.decimal  "actual_price",     precision: 10, scale: 2, default: 0.0
    end
  end
end
