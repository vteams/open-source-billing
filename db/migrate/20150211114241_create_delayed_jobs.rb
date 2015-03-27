class CreateDelayedJobs < ActiveRecord::Migration
  def change
    create_table :delayed_jobs do |t|
      t.integer  "priority",             default: 0
      t.integer  "attempts",             default: 0
      t.text     "handler"
      t.text     "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.string   "queue"
      t.datetime "created_at",                       null: false
      t.datetime "updated_at",                       null: false
      t.integer  "recurring_profile_id"
    end
    add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end
end
