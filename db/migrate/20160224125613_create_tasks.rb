class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.boolean :billable
      t.decimal :rate
      t.string   :archive_number
      t.datetime :archived_at
      t.time     :deleted_at

      t.timestamps
    end
  end
end
