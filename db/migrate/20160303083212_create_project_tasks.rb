class CreateProjectTasks < ActiveRecord::Migration
  def change
    create_table :project_tasks do |t|
      t.string :name
      t.text :description
      t.float :rate
      t.string :archive_number
      t.datetime :archived_at
      t.integer :project_id
      t.integer :task_id

      t.timestamps
    end
  end
end
