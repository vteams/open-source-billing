class CreateCategories < ActiveRecord::Migration
  def self.up
    unless table_exists? :categories
      create_table :categories do |t|
        t.string   "category"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
      end
    end
  end

  def self.down
    drop_table :categories if table_exists? :categories
  end
end
