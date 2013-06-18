class CreateCompanyEntities < ActiveRecord::Migration
  def change
    create_table :company_entities do |t|
      t.integer :entity_id
      t.string :entity_type
      t.integer :parent_id
      t.string :parent_type

      t.timestamps
    end
  end
end
