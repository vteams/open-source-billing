class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :project_id
      t.integer :task_id
      t.float :hours
      t.string :notes
      t.date :date
      t.integer :company_id

      t.timestamps
    end
  end
end
