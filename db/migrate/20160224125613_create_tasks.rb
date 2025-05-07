class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.boolean :billable
      t.float :rate
      t.string   :archive_number
      t.datetime :archived_at
      t.time     :deleted_at
      t.integer  :updated_by
      t.integer  :created_by
      t.integer  :project_id

      t.timestamps
    end
  end
end
