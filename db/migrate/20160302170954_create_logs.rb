class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :project_id
      t.integer :task_id
      t.float :hours
      t.string :notes
      t.datetime :date

      t.timestamps
    end
  end
end
