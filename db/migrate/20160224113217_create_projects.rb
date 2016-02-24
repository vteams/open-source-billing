class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :project_name
      t.integer :client_id
      t.integer :manager_id
      t.string :billing_method
      t.text :description
      t.integer :total_hours
      t.integer :company_id
      t.integer :updated_by
      t.integer :created_by
      t.string :archive_number
      t.datetime :archived_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
