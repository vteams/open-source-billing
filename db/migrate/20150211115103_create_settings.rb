class CreateSettings < ActiveRecord::Migration
  def self.up
    unless table_exists? :settings
      create_table :settings do |t|
        t.string   "var",                   null: false
        t.text     "value"
        t.integer  "thing_id"
        t.string   "thing_type", limit: 30
        t.datetime "created_at",            null: false
        t.datetime "updated_at",            null: false
      end
    end
  end

  def self.down
    drop_table :settings if table_exists? :settings
  end
end
