class CreateCompanyEntities < ActiveRecord::Migration
  def self.up
    unless table_exists? :company_entities
      create_table :company_entities do |t|
        t.integer  "entity_id"
        t.string   "entity_type"
        t.integer  "parent_id"
        t.string   "parent_type"
        t.datetime "created_at",  null: false
        t.datetime "updated_at",  null: false
      end
    end
  end

  def self.down
    drop_table :company_entities if table_exists? :company_entities
  end
end
