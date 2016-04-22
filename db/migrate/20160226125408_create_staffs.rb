class CreateStaffs < ActiveRecord::Migration
  def change
    create_table :staffs do |t|
      t.string :email
      t.string :name
      t.float :rate
      t.integer :created_by
      t.integer :updated_by
      t.string   :archive_number
      t.datetime :archived_at
      t.time     :deleted_at

      t.timestamps
    end
  end
end
