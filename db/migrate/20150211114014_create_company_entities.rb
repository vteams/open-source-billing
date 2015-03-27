class CreateCompanyEntities < ActiveRecord::Migration
  def change
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
