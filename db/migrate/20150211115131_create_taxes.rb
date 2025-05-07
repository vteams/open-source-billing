class CreateTaxes < ActiveRecord::Migration
  def change
    create_table :taxes do |t|
      t.string   "name"
      t.decimal  "percentage",     precision: 10, scale: 2
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
      t.string   "archive_number"
      t.datetime "archived_at"
      t.datetime "deleted_at"
    end
  end
end
