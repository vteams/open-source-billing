class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members do |t|
      t.string :email
      t.string :name
      t.float :rate
      t.string :archive_number
      t.datetime :archived_at
      t.integer :project_id
      t.integer :staff_id

      t.timestamps
    end
  end
end
