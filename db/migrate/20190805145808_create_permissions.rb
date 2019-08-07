class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.boolean :can_create
      t.boolean :can_update
      t.boolean :can_delete
      t.boolean :can_read
      t.string :entity_type
      t.references :role, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
